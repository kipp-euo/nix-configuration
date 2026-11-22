#include <algorithm>
#include <array>
#include <cerrno>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <dirent.h>
#include <dlfcn.h>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <memory>
#include <limits>
#include <optional>
#include <cctype>
#include <poll.h>
#include <queue>
#include <set>
#include <sstream>
#include <string>
#include <string_view>
#include <thread>
#include <unistd.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/un.h>
#include <vector>

namespace fs = std::filesystem;
using Clock = std::chrono::steady_clock;

namespace {
constexpr auto kSampleInterval = std::chrono::seconds(1);
constexpr std::uint64_t kSectorBytes = 512;

std::string readText(const fs::path& path) {
    std::ifstream input(path);
    if (!input) return {};
    std::ostringstream buffer;
    buffer << input.rdbuf();
    return buffer.str();
}

std::uint64_t readU64(const fs::path& path) {
    const auto text = readText(path);
    if (text.empty()) return 0;
    try { return std::stoull(text); } catch (...) { return 0; }
}

std::optional<std::uint64_t> readU64Optional(const fs::path& path) {
    std::ifstream file(path); std::uint64_t value = 0;
    if (!(file >> value)) return std::nullopt;
    return value;
}

std::string jsonOptional(const std::optional<std::uint64_t>& value) {
    return value ? std::to_string(*value) : "null";
}

std::string jsonEscape(std::string_view value) {
    std::ostringstream out;
    for (const unsigned char ch : value) {
        switch (ch) {
            case '"': out << "\\\""; break;
            case '\\': out << "\\\\"; break;
            case '\b': out << "\\b"; break;
            case '\f': out << "\\f"; break;
            case '\n': out << "\\n"; break;
            case '\r': out << "\\r"; break;
            case '\t': out << "\\t"; break;
            default:
                if (ch < 0x20) {
                    out << "\\u" << std::hex << std::setw(4) << std::setfill('0') << int(ch) << std::dec;
                } else out << ch;
        }
    }
    return out.str();
}

std::string jsonNumber(double value) {
    if (!std::isfinite(value)) return "null";
    std::ostringstream out;
    out << std::fixed << std::setprecision(2) << value;
    return out.str();
}

struct CpuCounters {
    std::string name;
    unsigned cpuId = 0;
    int packageId = 0;
    int coreId = 0;
    bool aggregate = false;
    std::uint64_t total = 0;
    std::uint64_t idle = 0;
};

struct CpuThreadSample {
    unsigned cpuId = 0;
    double usage = std::numeric_limits<double>::quiet_NaN();
};

struct CpuCoreSample {
    int packageId = 0;
    int coreId = 0;
    std::vector<CpuThreadSample> threads;
};

std::uint64_t cpuTotal(const std::array<std::uint64_t, 10>& fields, std::size_t count) {
    std::uint64_t total = 0;
    for (std::size_t i = 0; i < std::min<std::size_t>(count, 8); ++i) total += fields[i];
    return total;
}

std::vector<CpuCounters> readCpuCounters() {
    std::ifstream input("/proc/stat");
    std::vector<CpuCounters> result;
    std::string line;
    while (std::getline(input, line)) {
        std::istringstream row(line);
        CpuCounters counters;
        row >> counters.name;
        if (counters.name.rfind("cpu", 0) != 0) break;
        counters.aggregate = counters.name == "cpu";
        if (!counters.aggregate) {
            if (counters.name.size() <= 3 || !std::isdigit(static_cast<unsigned char>(counters.name[3]))) continue;
            try { counters.cpuId = static_cast<unsigned>(std::stoul(counters.name.substr(3))); }
            catch (...) { continue; }
            const auto topology = fs::path("/sys/devices/system/cpu") / ("cpu" + std::to_string(counters.cpuId)) / "topology";
            counters.packageId = static_cast<int>(readU64(topology / "physical_package_id"));
            counters.coreId = static_cast<int>(readU64(topology / "core_id"));
        }
        std::array<std::uint64_t, 10> fields{};
        std::size_t count = 0;
        while (count < fields.size() && row >> fields[count]) ++count;
        if (count < 4) continue;
        // guest and guest_nice (fields 8 and 9) are already included in
        // user and nice; summing them again distorts CPU utilization.
        counters.total = cpuTotal(fields, count);
        counters.idle = fields[3] + (count > 4 ? fields[4] : 0);
        result.push_back(counters);
    }
    return result;
}

double cpuCounterUsage(const CpuCounters& current, const CpuCounters* previous) {
    if (!previous || current.name != previous->name || current.total <= previous->total || current.idle < previous->idle)
        return std::numeric_limits<double>::quiet_NaN();
    const auto total = current.total - previous->total;
    const auto idle = current.idle - previous->idle;
    return 100.0 * (total - std::min(total, idle)) / total;
}

struct CpuSample {
    double usage = std::numeric_limits<double>::quiet_NaN();
    double frequencyMhz = std::numeric_limits<double>::quiet_NaN();
    double temperatureC = std::numeric_limits<double>::quiet_NaN();
    double load1 = 0, load5 = 0, load15 = 0;
    unsigned onlineCpus = 0;
    std::vector<CpuCoreSample> cores;
};

std::uint64_t parseMemValue(const std::map<std::string, std::uint64_t>& values, const std::string& key) {
    const auto found = values.find(key);
    return found == values.end() ? 0 : found->second * 1024;
}

struct MemorySample {
    bool meminfoAvailable = false;
    std::uint64_t total = 0, used = 0, available = 0, cached = 0;
    std::uint64_t swapTotal = 0, swapUsed = 0;
    std::uint64_t free = 0, buffers = 0, reclaimable = 0, slab = 0, shmem = 0;
    std::uint64_t zramOriginal = 0, zramCompressed = 0, zramMemory = 0, zramSize = 0;
    unsigned zramCount = 0;
    bool swapIoAvailable = false;
    std::uint64_t swapInBytes = 0, swapOutBytes = 0;
    double swapInRate = std::numeric_limits<double>::quiet_NaN(), swapOutRate = std::numeric_limits<double>::quiet_NaN();
    double psiSomeAvg10 = std::numeric_limits<double>::quiet_NaN();
    std::string zramAlgorithm;
};

struct BatteryDetail {
    std::string name, status;
    double energyWh = std::numeric_limits<double>::quiet_NaN();
    double fullWh = std::numeric_limits<double>::quiet_NaN();
    double designWh = std::numeric_limits<double>::quiet_NaN();
    double chargeAh = std::numeric_limits<double>::quiet_NaN();
    double fullAh = std::numeric_limits<double>::quiet_NaN();
    double designAh = std::numeric_limits<double>::quiet_NaN();
    double voltageV = std::numeric_limits<double>::quiet_NaN();
    double currentA = std::numeric_limits<double>::quiet_NaN();
    double powerW = std::numeric_limits<double>::quiet_NaN();
    double temperatureC = std::numeric_limits<double>::quiet_NaN();
    double cycleCount = std::numeric_limits<double>::quiet_NaN();
};
struct PowerDetails {
    std::vector<BatteryDetail> batteries;
    std::optional<bool> acOnline;
};

double readScaled(const fs::path& path, double divisor) {
    std::ifstream file(path); double value = 0;
    return file >> value ? value / divisor : std::numeric_limits<double>::quiet_NaN();
}

PowerDetails readPowerDetails(const fs::path& root, std::map<std::string, BatteryDetail>& cache, bool refreshStatic) {
    PowerDetails result;
    std::error_code ec;
    for (const auto& entry : fs::directory_iterator(root, ec)) {
        const auto type = readText(entry.path() / "type");
        if (type.find("Battery") != std::string::npos) {
            const auto name = entry.path().filename().string();
            const bool isNew = cache.find(name) == cache.end();
            auto& b = cache[name]; b.name = name; b.status = readText(entry.path() / "status");
            while (!b.status.empty() && std::isspace(static_cast<unsigned char>(b.status.back()))) b.status.pop_back();
            b.energyWh = readScaled(entry.path() / "energy_now", 1000000.0);
            b.chargeAh = readScaled(entry.path() / "charge_now", 1000000.0);
            b.voltageV = readScaled(entry.path() / "voltage_now", 1000000.0);
            b.currentA = readScaled(entry.path() / "current_now", 1000000.0);
            b.powerW = readScaled(entry.path() / "power_now", 1000000.0);
            if (std::isfinite(b.powerW) && b.status == "Discharging") b.powerW = -std::abs(b.powerW);
            else if (std::isfinite(b.powerW) && b.status == "Charging") b.powerW = std::abs(b.powerW);
            else if (b.status != "Charging" && b.status != "Discharging") b.powerW = std::numeric_limits<double>::quiet_NaN();
            b.temperatureC = readScaled(entry.path() / "temp", 10.0);
            if (isNew || refreshStatic) {
                b.fullWh = readScaled(entry.path() / "energy_full", 1000000.0);
                b.designWh = readScaled(entry.path() / "energy_full_design", 1000000.0);
                b.fullAh = readScaled(entry.path() / "charge_full", 1000000.0);
                b.designAh = readScaled(entry.path() / "charge_full_design", 1000000.0);
                b.cycleCount = readScaled(entry.path() / "cycle_count", 1.0);
            }
            result.batteries.push_back(b);
        } else if (type.find("Mains") != std::string::npos || type.find("USB") != std::string::npos) {
            const auto online = readU64Optional(entry.path() / "online");
            if (online) result.acOnline = result.acOnline.value_or(false) || *online != 0;
        }
    }
    return result;
}

std::string powerDetailsJson(const PowerDetails& power) {
    std::ostringstream out; out << "{\"acOnline\":";
    if (power.acOnline) out << (*power.acOnline ? "true" : "false"); else out << "null";
    out << ",\"batteries\":[";
    for (std::size_t i = 0; i < power.batteries.size(); ++i) {
        if (i) out << ',';
        const auto& b = power.batteries[i];
        out << "{\"name\":\"" << jsonEscape(b.name) << "\",\"status\":\"" << jsonEscape(b.status)
            << "\",\"energyWh\":" << jsonNumber(b.energyWh) << ",\"fullWh\":" << jsonNumber(b.fullWh)
            << ",\"designWh\":" << jsonNumber(b.designWh) << ",\"chargeAh\":" << jsonNumber(b.chargeAh)
            << ",\"fullAh\":" << jsonNumber(b.fullAh) << ",\"designAh\":" << jsonNumber(b.designAh)
            << ",\"voltageV\":" << jsonNumber(b.voltageV) << ",\"currentA\":" << jsonNumber(b.currentA) << ",\"powerW\":" << jsonNumber(b.powerW)
            << ",\"temperatureC\":" << jsonNumber(b.temperatureC) << ",\"cycleCount\":" << jsonNumber(b.cycleCount) << '}';
    }
    out << "]}"; return out.str();
}

double monotonicRate(std::uint64_t current, std::uint64_t previous, double elapsed, double scale = 1.0) {
    if (current < previous || elapsed <= 0 || !std::isfinite(elapsed)) return std::numeric_limits<double>::quiet_NaN();
    return static_cast<double>(current - previous) * scale / elapsed;
}

struct DiskCounter {
    std::uint64_t reads = 0, sectorsRead = 0, writes = 0, sectorsWritten = 0, ioMs = 0;
};
struct DiskSample {
    std::string name;
    double temperatureC = std::numeric_limits<double>::quiet_NaN();
    double readBytesPerSecond = std::numeric_limits<double>::quiet_NaN(), writeBytesPerSecond = std::numeric_limits<double>::quiet_NaN();
    double readIops = std::numeric_limits<double>::quiet_NaN(), writeIops = std::numeric_limits<double>::quiet_NaN(), utilization = std::numeric_limits<double>::quiet_NaN();
};

// Only a sensor explicitly attached to this block device is attributable to it.
// Do not substitute an arbitrary system NVMe/hwmon sensor.
double readDiskTemperature(const fs::path& blockDevice) {
    std::error_code ec;
    const auto hwmon = blockDevice / "device" / "hwmon";
    if (!fs::is_directory(hwmon, ec)) return std::numeric_limits<double>::quiet_NaN();
    for (const auto& entry : fs::directory_iterator(hwmon, ec)) {
        const auto value = readScaled(entry.path() / "temp1_input", 1000.0);
        if (std::isfinite(value)) return value;
    }
    return std::numeric_limits<double>::quiet_NaN();
}

struct NetCounter { std::uint64_t rx = 0, tx = 0; };
struct NetSample {
    std::string name, type, state, mac;
    std::vector<std::string> addresses;
    double linkSpeedMbps = std::numeric_limits<double>::quiet_NaN();
    double rxBytesPerSecond = std::numeric_limits<double>::quiet_NaN(), txBytesPerSecond = std::numeric_limits<double>::quiet_NaN();
    std::uint64_t rxBytes = 0, txBytes = 0;
};

struct FanSample {
    std::string hwmon;
    std::string label;
    std::uint64_t rpm = 0;
};
struct HwmonTemperature {
    std::string hwmon;
    std::string label;
    double temperatureC = std::numeric_limits<double>::quiet_NaN();
};

struct ProcessIdentity {
    int pid = 0;
    int parentPid = 0;
    std::string name;
    std::string state;
    std::uint64_t userTicks = 0;
    std::uint64_t systemTicks = 0;
    std::uint64_t startTicks = 0;
    long priority = 0;
    long nice = 0;
};

struct ProcessDetails {
    ProcessIdentity identity;
    std::uint64_t virtualPages = 0;
    std::uint64_t residentPages = 0;
    std::uint64_t readBytes = 0;
    std::uint64_t writeBytes = 0;
    std::uint64_t voluntarySwitches = 0;
    std::uint64_t involuntarySwitches = 0;
    unsigned threads = 0;
    unsigned fileDescriptors = 0;
    bool memoryAvailable = false, ioAvailable = false, fdsAvailable = false;
};

struct PreviousProcessCounters {
    std::uint64_t cpuTicks = 0;
    std::uint64_t readBytes = 0;
    std::uint64_t writeBytes = 0;
    std::uint64_t startTicks = 0;
    bool ioAvailable = false;
};

struct InspectorState {
    int pid = 0;
    std::uint64_t rootStartTicks = 0;
    unsigned cachedFdCoverage = 0;
    bool pssRequested = false;
    std::optional<std::uint64_t> cachedPssBytes;
    unsigned cachedPssCoverage = 0, cachedPssTotal = 0;
    Clock::time_point lastSample = Clock::now();
    Clock::time_point lastFdSample = Clock::time_point{};
    std::uint64_t cachedFdCount = 0;
    std::map<int, PreviousProcessCounters> previous;
};

struct InspectorSample {
    bool available = false;
    int pid = 0;
    unsigned memoryCoverage = 0, ioCoverage = 0, fdCoverage = 0, cpuCoverage = 0, groupCount = 0;
    unsigned pssCoverage = 0, pssTotal = 0;
    std::optional<std::uint64_t> pssBytes;
    std::string issue;
    std::string method = "PID + descendants";
    std::string state;
    double normalizedCpuPercent = std::numeric_limits<double>::quiet_NaN();
    double userSeconds = 0;
    double systemSeconds = 0;
    double uptimeSeconds = 0;
    double readBytesPerSecond = std::numeric_limits<double>::quiet_NaN();
    double writeBytesPerSecond = std::numeric_limits<double>::quiet_NaN();
    std::uint64_t rssBytes = 0;
    std::uint64_t virtualBytes = 0;
    std::uint64_t readBytes = 0;
    std::uint64_t writeBytes = 0;
    std::uint64_t voluntarySwitches = 0;
    std::uint64_t involuntarySwitches = 0;
    std::uint64_t fileDescriptors = 0;
    unsigned processCount = 0;
    unsigned threadCount = 0;
    long priority = 0;
    long nice = 0;
    std::vector<std::pair<int, std::string>> processes;
};

struct GpuSample {
    std::string name;
    std::string vendor;
    double usage = std::numeric_limits<double>::quiet_NaN();
    double temperatureC = std::numeric_limits<double>::quiet_NaN();
    double frequencyMhz = std::numeric_limits<double>::quiet_NaN();
    double powerW = std::numeric_limits<double>::quiet_NaN();
    double memoryUsage = std::numeric_limits<double>::quiet_NaN();
    double memoryFrequencyMhz = std::numeric_limits<double>::quiet_NaN();
    std::optional<std::uint64_t> vramUsed, vramTotal;
    std::optional<std::uint64_t> gttUsed, gttTotal;
    std::string source;
};

class NvidiaNvml {
public:
    NvidiaNvml() {
        std::vector<std::string> candidates;
        if (const char* configuredPath = std::getenv("NVML_LIBRARY_PATH"); configuredPath && *configuredPath) {
            candidates.emplace_back(configuredPath);
        }
        candidates.emplace_back("/run/opengl-driver/lib/libnvidia-ml.so.1");
        candidates.emplace_back("/run/opengl-driver/lib/libnvidia-ml.so");
        candidates.emplace_back("/run/current-system/sw/lib/libnvidia-ml.so.1");
        candidates.emplace_back("/run/current-system/sw/lib/libnvidia-ml.so");
        candidates.emplace_back("libnvidia-ml.so.1");

        std::ostringstream failures;
        for (const auto& candidate : candidates) {
            dlerror();
            library_ = dlopen(candidate.c_str(), RTLD_NOW | RTLD_LOCAL);
            if (library_) {
                libraryPath_ = candidate;
                break;
            }
            const char* error = dlerror();
            if (failures.tellp() > 0) failures << "; ";
            failures << candidate << ": " << (error ? error : "unknown dlopen error");
        }

        if (!library_) {
            status_ = "NVML library could not be loaded";
            if (failures.tellp() > 0) status_ += " (" + failures.str() + ")";
            return;
        }

        init_ = symbol<InitFn>("nvmlInit_v2", "nvmlInit");
        shutdown_ = symbol<ShutdownFn>("nvmlShutdown");
        getCount_ = symbol<GetCountFn>("nvmlDeviceGetCount_v2", "nvmlDeviceGetCount");
        getHandle_ = symbol<GetHandleFn>("nvmlDeviceGetHandleByIndex_v2", "nvmlDeviceGetHandleByIndex");
        getUtil_ = symbol<GetUtilFn>("nvmlDeviceGetUtilizationRates");
        getTemp_ = symbol<GetTempFn>("nvmlDeviceGetTemperature");
        getClock_ = symbol<GetClockFn>("nvmlDeviceGetClockInfo");
        getMemory_ = symbol<GetMemoryFn>("nvmlDeviceGetMemoryInfo");
        getPower_ = symbol<GetPowerFn>("nvmlDeviceGetPowerUsage");
        getName_ = symbol<GetNameFn>("nvmlDeviceGetName");
        errorString_ = symbol<ErrorStringFn>("nvmlErrorString");

        if (!init_ || !getCount_ || !getHandle_) {
            status_ = "NVML library loaded from " + libraryPath_ + ", but required symbols are missing";
            closeLibrary();
            return;
        }

        const int initResult = init_();
        if (initResult != 0) {
            status_ = "NVML initialization failed: " + errorText(initResult);
            closeLibrary();
            return;
        }
        initialized_ = true;

        unsigned count = 0;
        const int countResult = getCount_(&count);
        if (countResult != 0) {
            status_ = "NVML loaded from " + libraryPath_ + ", but device enumeration failed: " + errorText(countResult);
            closeLibrary();
            return;
        }
        count_ = count;
        if (count_ == 0) {
            status_ = "NVML initialized from " + libraryPath_ + ", but it reported zero devices";
            closeLibrary();
            return;
        }
        status_ = "NVML ready: " + std::to_string(count_) + " device(s) via " + libraryPath_;
    }

    ~NvidiaNvml() { closeLibrary(); }

    bool available() const { return library_ && initialized_ && count_ > 0; }
    const std::string& status() const { return status_; }
    const std::string& libraryPath() const { return libraryPath_; }

    std::vector<GpuSample> sample() const {
        std::vector<GpuSample> result;
        if (!available()) return result;
        for (unsigned i = 0; i < count_; ++i) {
            void* device = nullptr;
            if (getHandle_(i, &device) != 0 || !device) continue;
            GpuSample gpu;
            gpu.name = "NVIDIA GPU " + std::to_string(i);
            char name[128]{};
            if (getName_ && getName_(device, name, sizeof(name)) == 0 && name[0]) gpu.name = name;
            gpu.vendor = "nvidia";
            gpu.source = "NVML";
            Utilization utilization{};
            if (getUtil_ && getUtil_(device, &utilization) == 0) { gpu.usage = utilization.gpu; gpu.memoryUsage = utilization.memory; }
            unsigned temperature = 0;
            if (getTemp_ && getTemp_(device, 0, &temperature) == 0) gpu.temperatureC = temperature;
            unsigned clock = 0;
            if (getClock_ && getClock_(device, 0, &clock) == 0) gpu.frequencyMhz = clock;
            if (getClock_ && getClock_(device, 2, &clock) == 0) gpu.memoryFrequencyMhz = clock;
            Memory memory{};
            if (getMemory_ && getMemory_(device, &memory) == 0) {
                gpu.vramUsed = memory.used;
                gpu.vramTotal = memory.total;
            }
            unsigned powerMilliwatts = 0;
            if (getPower_ && getPower_(device, &powerMilliwatts) == 0) gpu.powerW = powerMilliwatts / 1000.0;
            result.push_back(gpu);
        }
        return result;
    }

private:
    struct Utilization { unsigned gpu = 0, memory = 0; };
    struct Memory { unsigned long long total = 0, free = 0, used = 0; };
    using InitFn = int (*)();
    using ShutdownFn = int (*)();
    using GetCountFn = int (*)(unsigned*);
    using GetHandleFn = int (*)(unsigned, void**);
    using GetUtilFn = int (*)(void*, Utilization*);
    using GetTempFn = int (*)(void*, unsigned, unsigned*);
    using GetClockFn = int (*)(void*, unsigned, unsigned*);
    using GetMemoryFn = int (*)(void*, Memory*);
    using GetPowerFn = int (*)(void*, unsigned*);
    using GetNameFn = int (*)(void*, char*, unsigned);
    using ErrorStringFn = const char* (*)(int);

    template <typename T> T symbol(const char* primary, const char* fallback = nullptr) {
        auto* value = dlsym(library_, primary);
        if (!value && fallback) value = dlsym(library_, fallback);
        return reinterpret_cast<T>(value);
    }

    std::string errorText(int code) const {
        if (errorString_) {
            const char* message = errorString_(code);
            if (message) return std::string(message) + " (code " + std::to_string(code) + ")";
        }
        return "NVML error code " + std::to_string(code);
    }

    void closeLibrary() {
        if (library_) {
            if (initialized_ && shutdown_) shutdown_();
            dlclose(library_);
        }
        library_ = nullptr;
        initialized_ = false;
        count_ = 0;
    }

    void* library_ = nullptr;
    bool initialized_ = false;
    unsigned count_ = 0;
    std::string libraryPath_;
    std::string status_ = "NVML not initialized";
    InitFn init_ = nullptr;
    ShutdownFn shutdown_ = nullptr;
    GetCountFn getCount_ = nullptr;
    GetHandleFn getHandle_ = nullptr;
    GetUtilFn getUtil_ = nullptr;
    GetTempFn getTemp_ = nullptr;
    GetClockFn getClock_ = nullptr;
    GetMemoryFn getMemory_ = nullptr;
    GetPowerFn getPower_ = nullptr;
    GetNameFn getName_ = nullptr;
    ErrorStringFn errorString_ = nullptr;
};

std::vector<std::string> detectNvidiaPciDevices() {
    std::vector<std::string> devices;
    std::error_code ec;
    const fs::path root("/sys/bus/pci/devices");
    if (!fs::exists(root, ec)) return devices;
    for (const auto& entry : fs::directory_iterator(root, ec)) {
        if (readText(entry.path() / "vendor").find("0x10de") == std::string::npos) continue;
        const auto classId = readText(entry.path() / "class");
        if (classId.rfind("0x03", 0) != 0) continue;
        devices.push_back(entry.path().filename().string());
    }
    return devices;
}

void appendNvidiaPciFallback(std::vector<GpuSample>& samples, const std::vector<std::string>& pciDevices) {
    // A DRM device already reports the NVIDIA adapter; avoid duplicating it.
    if (std::any_of(samples.begin(), samples.end(), [](const GpuSample& gpu) { return gpu.vendor == "nvidia"; })) return;
    for (const auto& address : pciDevices) {
        GpuSample gpu;
        gpu.name = "NVIDIA · " + address;
        gpu.vendor = "nvidia";
        gpu.source = "PCI detection only · metrics unavailable";
        samples.push_back(std::move(gpu));
    }
}

// Extract keyboard objects only: device JSON starts with mice and can arrive in
// several socket reads. Prefer Hyprland's main keyboard over secondary devices.
std::string parseKeyboardLayout(const std::string& response) {
    const auto key = response.find("\"keyboards\"");
    if (key == std::string::npos) return "N/A";
    auto pos = response.find('[', key);
    if (pos == std::string::npos) return "N/A";
    int depth = 0; bool quoted = false, escaped = false; std::size_t start = 0;
    std::string fallback;
    for (++pos; pos < response.size(); ++pos) {
        const char c = response[pos];
        if (quoted) { if (escaped) escaped = false; else if (c == '\\') escaped = true; else if (c == '"') quoted = false; continue; }
        if (c == '"') { quoted = true; continue; }
        if (c == '{') { if (depth++ == 0) start = pos; }
        else if (c == '}' && depth > 0 && --depth == 0) {
            const auto object = response.substr(start, pos - start + 1);
            auto layoutPos = object.find("\"active_keymap\"");
            if (layoutPos == std::string::npos) continue;
            layoutPos = object.find(':', layoutPos);
            if (layoutPos == std::string::npos) continue;
            const auto begin = object.find('"', layoutPos + 1);
            if (begin == std::string::npos) continue;
            std::string layout;
            bool ended = false;
            for (auto i = begin + 1; i < object.size(); ++i) {
                const char ch = object[i];
                if (ch == '"') { ended = true; break; }
                if (ch == '\\' && i + 1 < object.size()) {
                    const char escaped = object[++i];
                    if (escaped == 'n') layout += '\n';
                    else if (escaped == 'r') layout += '\r';
                    else if (escaped == 't') layout += '\t';
                    else if (escaped == '"' || escaped == '\\' || escaped == '/') layout += escaped;
                    else { layout += '\\'; layout += escaped; }
                } else layout += ch;
            }
            if (!ended) continue;
            auto mainPos = object.find("\"main\"");
            bool main = false;
            if (mainPos != std::string::npos) {
                mainPos = object.find(':', mainPos);
                if (mainPos != std::string::npos) {
                    mainPos = object.find_first_not_of(" \t\r\n", mainPos + 1);
                    main = mainPos != std::string::npos && object.compare(mainPos, 4, "true") == 0;
                }
            }
            if (fallback.empty()) fallback = layout;
            if (main) { fallback = layout; break; }
        } else if (c == ']' && depth == 0) break;
    }
    if (fallback.empty()) return "N/A";
    auto normalized = fallback;
    std::transform(normalized.begin(), normalized.end(), normalized.begin(), [](unsigned char v) { return static_cast<char>(std::tolower(v)); });
    if (normalized.find("russian") != std::string::npos || normalized == "ru" || normalized.rfind("ru(", 0) == 0) return "RU";
    if (normalized.find("english") != std::string::npos || normalized == "us" || normalized == "gb" || normalized.rfind("us(", 0) == 0) return "EN";
    return fallback;
}

std::string hyprlandRequest(const std::string& request) {
    const char* runtimeDir = std::getenv("XDG_RUNTIME_DIR");
    const char* signature = std::getenv("HYPRLAND_INSTANCE_SIGNATURE");
    if (!runtimeDir || !signature) return {};

    const auto socketPath = std::string(runtimeDir) + "/hypr/" + signature + "/.socket.sock";
    const int socketFd = ::socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (socketFd < 0) return {};

    sockaddr_un address{};
    address.sun_family = AF_UNIX;
    if (socketPath.size() >= sizeof(address.sun_path)) {
        ::close(socketFd);
        return {};
    }
    std::strncpy(address.sun_path, socketPath.c_str(), sizeof(address.sun_path) - 1);
    timeval timeout{0, 250000};
    setsockopt(socketFd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    if (::connect(socketFd, reinterpret_cast<sockaddr*>(&address), sizeof(address)) != 0) {
        ::close(socketFd);
        return {};
    }

    if (::send(socketFd, request.data(), request.size(), MSG_NOSIGNAL) != static_cast<ssize_t>(request.size())) {
        ::close(socketFd);
        return {};
    }
    std::string response;
    char buffer[4096];
    while (response.size() < 65536) {
        const auto bytes = ::recv(socketFd, buffer, sizeof(buffer), 0);
        if (bytes <= 0) break;
        response.append(buffer, static_cast<std::size_t>(bytes));
    }
    ::close(socketFd);

    return response;
}

std::string readHyprlandKeyboardLayout() {
    return parseKeyboardLayout(hyprlandRequest("j/devices"));
}

bool supportsUefiSetup() {
    const fs::path root("/sys/firmware/efi/efivars");
    std::error_code ec;
    if (!fs::exists(root, ec)) return false;
    for (const auto& entry : fs::directory_iterator(root, ec)) {
        const auto name = entry.path().filename().string();
        if (name.rfind("OsIndicationsSupported-", 0) != 0) continue;
        std::ifstream file(entry.path(), std::ios::binary);
        if (!file) continue;
        std::uint32_t attributes = 0;
        std::uint64_t indications = 0;
        file.read(reinterpret_cast<char*>(&attributes), sizeof(attributes));
        file.read(reinterpret_cast<char*>(&indications), sizeof(indications));
        if (file.gcount() == static_cast<std::streamsize>(sizeof(indications)) && (indications & 1ULL)) return true;
    }
    return false;
}

class Collector {
public:
    Collector() : nvml_(std::make_unique<NvidiaNvml>()), keyboardLayout_(readHyprlandKeyboardLayout()), uefiSetupSupported_(supportsUefiSetup()), lastKeyboardCheck_(Clock::now()) {}

#ifdef QS_TELEMETRY_TEST
    std::vector<GpuSample> testSampleGpus(const fs::path& root) { return sampleGpus(false, root); }
#endif
    void setInspector(const std::string& slot, int pid) {
        if (slot.empty() || pid <= 0) return;
        auto& state = inspectorStates_[slot];
        if (state.pid != pid) {
            state = InspectorState{};
            state.pid = pid;
        }
    }

    void requestInspectorPss(const std::string& slot) {
        auto state = inspectorStates_.find(slot);
        if (state != inspectorStates_.end()) state->second.pssRequested = true;
    }

    void clearInspector(const std::string& slot) {
        inspectorStates_.erase(slot);
    }

    std::string collect(const std::string& group = "all") {
        std::ostringstream json;
        json << '{';
        bool first = true;
        auto add = [&](const std::string& key, const std::string& value) {
            if (!first) json << ',';
            first = false;
            json << '"' << key << "\":" << value;
        };
        add("timestampMs", std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count()));
        if (group == "keyboard" || (group == "all" && Clock::now() - lastKeyboardCheck_ >= std::chrono::seconds(5))) {
            keyboardLayout_ = readHyprlandKeyboardLayout();
            lastKeyboardCheck_ = Clock::now();
        }
        add("keyboardLayout", "\"" + jsonEscape(keyboardLayout_) + "\"");
        add("uefiSetupSupported", uefiSetupSupported_ ? "true" : "false");

        const auto now = Clock::now();
        if (lastFanSample_.time_since_epoch().count() == 0 || now - lastFanSample_ >= std::chrono::seconds(2)) {
            fans_ = sampleFans();
            lastFanSample_ = now;
        }
        if (lastHwmonSample_.time_since_epoch().count() == 0 || now - lastHwmonSample_ >= std::chrono::seconds(5)) {
            hwmonTemperatures_ = sampleHwmonTemperatures();
            lastHwmonSample_ = now;
        }
        add("fans", fansJson(fans_));
        add("hwmonTemperatures", hwmonJson(hwmonTemperatures_));
        if (group == "battery" || lastPowerSample_.time_since_epoch().count() == 0 || now - lastPowerSample_ >= std::chrono::seconds(5)) {
            powerDetails_ = readPowerDetails("/sys/class/power_supply", batteryCache_, group == "battery");
            lastPowerSample_ = now;
        }
        if (lastPowerRateSample_.time_since_epoch().count() == 0 || now - lastPowerRateSample_ >= std::chrono::seconds(1)) {
            for (auto& battery : powerDetails_.batteries) {
                const auto path = fs::path("/sys/class/power_supply") / battery.name;
                battery.powerW = readScaled(path / "power_now", 1000000.0);
                if (std::isfinite(battery.powerW) && battery.status == "Discharging") battery.powerW = -std::abs(battery.powerW);
                else if (std::isfinite(battery.powerW) && battery.status == "Charging") battery.powerW = std::abs(battery.powerW);
                else battery.powerW = std::numeric_limits<double>::quiet_NaN();
            }
            lastPowerRateSample_ = now;
        }
        add("powerDetails", powerDetailsJson(powerDetails_));

        std::map<std::string, InspectorSample> inspectorSamples;
        for (auto& [slot, state] : inspectorStates_) inspectorSamples.emplace(slot, sampleInspector(slot, state));
        add("inspectors", inspectorsJson(inspectorSamples));

        if (group == "all" || group == "cpu") add("cpu", cpuJson(sampleCpu()));
        if (group == "all" || group == "gpu" || group == "vram") {
            const auto gpus = sampleGpus(group == "gpu" || group == "vram");
            add("gpus", gpuJson(gpus));
            add("gpuStatus", "\"" + jsonEscape(gpuStatus_) + "\"");
        }
        if (group == "all" || group == "ram") add("memory", memoryJson(sampleMemory()));
        if (group == "all" || group == "disk") {
            const auto now = Clock::now();
            const double elapsed = std::max(0.001, std::chrono::duration<double>(now - lastDiskSample_).count());
            lastDiskSample_ = now;
            add("disks", diskJson(sampleDisks(elapsed)));
        }
        if (group == "all" || group == "network") {
            const auto now = Clock::now();
            const double elapsed = std::max(0.001, std::chrono::duration<double>(now - lastNetworkSample_).count());
            lastNetworkSample_ = now;
            add("networks", networkJson(sampleNetworks(elapsed)));
        }
        json << '}';
        return json.str();
    }

private:
    static bool readProcessIdentity(int pid, ProcessIdentity& identity) {
        const auto stat = readText(fs::path("/proc") / std::to_string(pid) / "stat");
        const auto open = stat.find('(');
        const auto close = stat.rfind(')');
        if (open == std::string::npos || close == std::string::npos || close <= open) return false;

        identity.pid = pid;
        identity.name = stat.substr(open + 1, close - open - 1);
        std::istringstream fields(stat.substr(close + 2));
        std::vector<std::string> values;
        std::string field;
        while (fields >> field) values.push_back(field);
        if (values.size() < 22) return false;
        try {
            identity.state = values[0];
            identity.parentPid = std::stoi(values[1]);
            identity.userTicks = std::stoull(values[11]);
            identity.systemTicks = std::stoull(values[12]);
            identity.priority = std::stol(values[15]);
            identity.nice = std::stol(values[16]);
            identity.startTicks = std::stoull(values[19]);
        } catch (...) { return false; }
        return true;
    }

    static unsigned countDirectoryEntries(const fs::path& path) {
        std::error_code ec;
        if (!fs::exists(path, ec)) return 0;
        unsigned count = 0;
        for (const auto& entry : fs::directory_iterator(path, ec)) {
            (void)entry;
            ++count;
        }
        return count;
    }

    static ProcessDetails readProcessDetails(const ProcessIdentity& identity, bool includeFdCount) {
        ProcessDetails details;
        details.identity = identity;
        const auto root = fs::path("/proc") / std::to_string(identity.pid);
        {
            std::ifstream input(root / "statm");
            details.memoryAvailable = static_cast<bool>(input >> details.virtualPages >> details.residentPages);
        }
        {
            std::ifstream input(root / "io");
            details.ioAvailable = static_cast<bool>(input);
            std::string key;
            std::uint64_t value = 0;
            while (input >> key >> value) {
                if (key == "read_bytes:") details.readBytes = value;
                else if (key == "write_bytes:") details.writeBytes = value;
            }
        }
        {
            std::ifstream input(root / "status");
            std::string line;
            while (std::getline(input, line)) {
                auto parseValue = [&](const char* prefix, std::uint64_t& target) {
                    const std::string marker(prefix);
                    if (line.rfind(marker, 0) != 0) return;
                    try { target = std::stoull(line.substr(marker.size())); } catch (...) {}
                };
                std::uint64_t threads = details.threads;
                parseValue("Threads:", threads);
                details.threads = static_cast<unsigned>(threads);
                parseValue("voluntary_ctxt_switches:", details.voluntarySwitches);
                parseValue("nonvoluntary_ctxt_switches:", details.involuntarySwitches);
            }
        }
        if (details.threads == 0) details.threads = countDirectoryEntries(root / "task");
        if (includeFdCount) {
            std::error_code ec;
            fs::directory_iterator iter(root / "fd", ec);
            if (!ec) {
                details.fdsAvailable = true;
                for (; iter != fs::directory_iterator(); iter.increment(ec)) {
                    if (ec) { details.fdsAvailable = false; break; }
                    ++details.fileDescriptors;
                }
            }
        }
        return details;
    }

    static std::vector<ProcessIdentity> readProcessIdentities() {
        std::vector<ProcessIdentity> result;
        std::error_code ec;
        for (const auto& entry : fs::directory_iterator("/proc", ec)) {
            const auto name = entry.path().filename().string();
            if (name.empty() || !std::all_of(name.begin(), name.end(), [](unsigned char c) { return std::isdigit(c); })) continue;
            int pid = 0;
            try { pid = std::stoi(name); } catch (...) { continue; }
            ProcessIdentity identity;
            if (readProcessIdentity(pid, identity)) result.push_back(std::move(identity));
        }
        return result;
    }

    static std::vector<int> appCgroupPids(int rootPid) {
        const auto cgroupText = readText(fs::path("/proc") / std::to_string(rootPid) / "cgroup");
        const auto marker = cgroupText.find("0::/");
        if (marker == std::string::npos) return {};
        auto relative = cgroupText.substr(marker + 4);
        while (!relative.empty() && (relative.back() == '\n' || relative.back() == '\r')) relative.pop_back();
        const auto componentStart = relative.find_last_of('/');
        const auto component = relative.substr(componentStart == std::string::npos ? 0 : componentStart + 1);
        if (component.rfind("app-", 0) != 0 || component.size() < 7 || component.substr(component.size() - 6) != ".scope") return {};

        const auto groupRoot = fs::path("/sys/fs/cgroup") / relative;
        std::error_code ec;
        if (!fs::exists(groupRoot / "cgroup.procs", ec)) return {};
        std::set<int> pids;
        auto readGroup = [&](const fs::path& group) {
            std::ifstream input(group / "cgroup.procs");
            int pid = 0;
            while (input >> pid) if (pid > 0) pids.insert(pid);
        };
        readGroup(groupRoot);
        for (const auto& entry : fs::recursive_directory_iterator(groupRoot, ec)) {
            if (entry.is_directory(ec)) readGroup(entry.path());
        }
        if (!pids.contains(rootPid)) return {};
        return {pids.begin(), pids.end()};
    }

    InspectorSample sampleInspector(const std::string& slot, InspectorState& state) {
        InspectorSample sample;
        sample.pid = state.pid;
        if (state.pid <= 0) return sample;

        const auto now = Clock::now();
        const double elapsed = std::max(0.001, std::chrono::duration<double>(now - state.lastSample).count());
        state.lastSample = now;

        std::vector<ProcessIdentity> identities;
        identities = readProcessIdentities();
        std::map<int, ProcessIdentity> byPid;
        std::map<int, std::vector<int>> children;
        for (const auto& identity : identities) {
            byPid.emplace(identity.pid, identity);
            children[identity.parentPid].push_back(identity.pid);
        }

        const auto root = byPid.find(state.pid);
        if (root == byPid.end()) {
            state.previous.clear();
            state.cachedFdCount = 0;
            sample.method = "PID only";
            return sample;
        }

        if (state.rootStartTicks == 0) state.rootStartTicks = root->second.startTicks;
        if (root->second.startTicks != state.rootStartTicks) {
            sample.issue = "Tracked PID was reused; reopen Inspector to select the new process";
            state.previous.clear();
            return sample;
        }
        auto cgroupPids = appCgroupPids(state.pid);
        std::set<int> selected;
        if (!cgroupPids.empty()) {
            selected.insert(cgroupPids.begin(), cgroupPids.end());
            sample.method = "app-specific cgroup";
        } else {
            sample.method = "PID + descendants";
            std::queue<int> pending;
            pending.push(state.pid);
            while (!pending.empty()) {
                const int current = pending.front();
                pending.pop();
                if (!selected.insert(current).second) continue;
                const auto found = children.find(current);
                if (found != children.end()) for (const int child : found->second) pending.push(child);
            }
        }

        if (sample.method == "PID + descendants" && selected.size() == 1) sample.method = "PID only";
        sample.groupCount = static_cast<unsigned>(selected.size());
        const bool updateFds = state.lastFdSample.time_since_epoch().count() == 0 || now - state.lastFdSample >= std::chrono::seconds(5);
        const long ticksPerSecond = std::max(1L, ::sysconf(_SC_CLK_TCK));
        const long pageSize = std::max(1L, ::sysconf(_SC_PAGESIZE));
        std::uint64_t deltaCpuTicks = 0;
        std::uint64_t deltaReadBytes = 0;
        std::uint64_t deltaWriteBytes = 0;
        std::uint64_t fdCount = 0, pssBytes = 0;
        unsigned pssCoverage = 0;
        unsigned fdCoverage = 0, deltaCpuCoverage = 0, deltaIoCoverage = 0;
        std::map<int, PreviousProcessCounters> nextPrevious;

        for (const int pid : selected) {
            const auto found = byPid.find(pid);
            if (found == byPid.end()) continue;
            const auto details = readProcessDetails(found->second, updateFds);
            if (state.pssRequested) {
                std::ifstream smaps(fs::path("/proc") / std::to_string(pid) / "smaps_rollup");
                std::string line;
                while (std::getline(smaps, line)) {
                    if (line.rfind("Pss:", 0) != 0) continue;
                    std::istringstream value(line.substr(4));
                    std::uint64_t kib = 0; std::string unit;
                    if (value >> kib >> unit && unit == "kB") { pssBytes += kib * 1024; ++pssCoverage; }
                    break;
                }
            }
            const auto cpuTicks = details.identity.userTicks + details.identity.systemTicks;
            const auto previous = state.previous.find(pid);
            if (previous != state.previous.end() && previous->second.startTicks == details.identity.startTicks) {
                deltaCpuTicks += cpuTicks - std::min(cpuTicks, previous->second.cpuTicks);
                ++deltaCpuCoverage;
                if (details.ioAvailable && previous->second.ioAvailable) {
                    deltaReadBytes += details.readBytes - std::min(details.readBytes, previous->second.readBytes);
                    deltaWriteBytes += details.writeBytes - std::min(details.writeBytes, previous->second.writeBytes);
                    ++deltaIoCoverage;
                }
            }
            nextPrevious[pid] = {cpuTicks, details.readBytes, details.writeBytes, details.identity.startTicks, details.ioAvailable};

            sample.userSeconds += details.identity.userTicks / static_cast<double>(ticksPerSecond);
            sample.systemSeconds += details.identity.systemTicks / static_cast<double>(ticksPerSecond);
            if (details.memoryAvailable) ++sample.memoryCoverage;
            if (details.ioAvailable) ++sample.ioCoverage;
            sample.rssBytes += details.residentPages * static_cast<std::uint64_t>(pageSize);
            sample.virtualBytes += details.virtualPages * static_cast<std::uint64_t>(pageSize);
            sample.readBytes += details.readBytes;
            sample.writeBytes += details.writeBytes;
            sample.voluntarySwitches += details.voluntarySwitches;
            sample.involuntarySwitches += details.involuntarySwitches;
            sample.threadCount += details.threads;
            if (updateFds && details.fdsAvailable) { fdCount += details.fileDescriptors; ++fdCoverage; }
            if (sample.processes.size() < 64) sample.processes.emplace_back(pid, details.identity.name);
            if (pid == state.pid) {
                sample.state = details.identity.state;
                sample.priority = details.identity.priority;
                sample.nice = details.identity.nice;
                const auto uptimeText = readText("/proc/uptime");
                double systemUptime = 0;
                std::istringstream uptimeStream(uptimeText);
                uptimeStream >> systemUptime;
                sample.uptimeSeconds = std::max(0.0, systemUptime - details.identity.startTicks / static_cast<double>(ticksPerSecond));
            }
            ++sample.processCount;
        }

        if (updateFds) {
            state.cachedFdCount = fdCount;
            state.cachedFdCoverage = fdCoverage;
            state.lastFdSample = now;
        }
        if (state.pssRequested) {
            state.cachedPssBytes = pssCoverage ? std::optional<std::uint64_t>(pssBytes) : std::nullopt;
            state.cachedPssCoverage = pssCoverage; state.cachedPssTotal = sample.groupCount;
            state.pssRequested = false;
        }
        sample.pssBytes = state.cachedPssBytes;
        sample.pssCoverage = state.cachedPssCoverage;
        sample.pssTotal = state.cachedPssTotal;
        sample.fileDescriptors = state.cachedFdCount;
        sample.fdCoverage = state.cachedFdCoverage;
        if (deltaIoCoverage > 0) {
            sample.readBytesPerSecond = deltaReadBytes / elapsed;
            sample.writeBytesPerSecond = deltaWriteBytes / elapsed;
        }
        const auto onlineCpus = std::max(1U, static_cast<unsigned>(std::max(1L, ::sysconf(_SC_NPROCESSORS_ONLN))));
        if (deltaCpuCoverage > 0) {
            sample.normalizedCpuPercent = 100.0 * deltaCpuTicks / (ticksPerSecond * elapsed * onlineCpus);
            sample.normalizedCpuPercent = std::clamp(sample.normalizedCpuPercent, 0.0, 100.0);
        }
        sample.cpuCoverage = deltaCpuCoverage;
        if (sample.processCount < sample.groupCount && sample.issue.empty()) sample.issue = "Some group processes disappeared or were inaccessible during collection.";
        sample.available = sample.processCount > 0;
        state.previous = std::move(nextPrevious);
        (void)slot;
        return sample;
    }

    static std::string inspectorsJson(const std::map<std::string, InspectorSample>& samples) {
        std::ostringstream out; out << '{';
        bool first = true;
        for (const auto& [slot, sample] : samples) {
            if (!first) out << ',';
            first = false;
            out << "\"" << jsonEscape(slot) << "\":{";
            out << "\"available\":" << (sample.available ? "true" : "false")
                << ",\"pid\":" << sample.pid
                << ",\"method\":\"" << jsonEscape(sample.method) << "\""
                << ",\"issue\":\"" << jsonEscape(sample.issue) << "\""
                << ",\"pssBytes\":" << jsonOptional(sample.pssBytes) << ",\"pssCoverage\":" << sample.pssCoverage << ",\"pssTotal\":" << sample.pssTotal
                << ",\"groupCount\":" << sample.groupCount << ",\"cpuCoverage\":" << sample.cpuCoverage
                << ",\"memoryCoverage\":" << sample.memoryCoverage << ",\"ioCoverage\":" << sample.ioCoverage << ",\"fdCoverage\":" << sample.fdCoverage
                << ",\"state\":\"" << jsonEscape(sample.state) << "\""
                << ",\"cpuNormalizedPercent\":" << jsonNumber(sample.normalizedCpuPercent)
                << ",\"userSeconds\":" << jsonNumber(sample.userSeconds)
                << ",\"systemSeconds\":" << jsonNumber(sample.systemSeconds)
                << ",\"uptimeSeconds\":" << jsonNumber(sample.uptimeSeconds)
                << ",\"rssBytes\":" << (sample.memoryCoverage ? std::to_string(sample.rssBytes) : "null")
                << ",\"virtualBytes\":" << (sample.memoryCoverage ? std::to_string(sample.virtualBytes) : "null")
                << ",\"readBytes\":" << (sample.ioCoverage ? std::to_string(sample.readBytes) : "null")
                << ",\"writeBytes\":" << (sample.ioCoverage ? std::to_string(sample.writeBytes) : "null")
                << ",\"readBytesPerSecond\":" << jsonNumber(sample.readBytesPerSecond)
                << ",\"writeBytesPerSecond\":" << jsonNumber(sample.writeBytesPerSecond)
                << ",\"voluntarySwitches\":" << sample.voluntarySwitches
                << ",\"involuntarySwitches\":" << sample.involuntarySwitches
                << ",\"fileDescriptors\":" << (sample.fdCoverage ? std::to_string(sample.fileDescriptors) : "null")
                << ",\"processCount\":" << sample.processCount
                << ",\"threadCount\":" << sample.threadCount
                << ",\"priority\":" << sample.priority
                << ",\"nice\":" << sample.nice
                << ",\"processes\":[";
            for (std::size_t i = 0; i < sample.processes.size(); ++i) {
                if (i) out << ',';
                out << "{\"pid\":" << sample.processes[i].first
                    << ",\"name\":\"" << jsonEscape(sample.processes[i].second) << "\"}";
            }
            out << "]}";
        }
        out << '}'; return out.str();
    }

    std::vector<FanSample> sampleFans() const {
        std::vector<FanSample> result;
        std::error_code ec;
        const fs::path root("/sys/class/hwmon");
        if (!fs::exists(root, ec)) return result;
        for (const auto& hwmonEntry : fs::directory_iterator(root, ec)) {
            const auto hwmonName = readText(hwmonEntry.path() / "name");
            std::string cleanName = hwmonName;
            while (!cleanName.empty() && std::isspace(static_cast<unsigned char>(cleanName.back()))) cleanName.pop_back();
            for (const auto& file : fs::directory_iterator(hwmonEntry.path(), ec)) {
                const auto filename = file.path().filename().string();
                if (filename.rfind("fan", 0) != 0 || filename.size() < 10 || filename.find("_input") == std::string::npos) continue;
                const auto rpm = readU64Optional(file.path());
                if (!rpm) continue;
                const auto prefix = filename.substr(0, filename.find("_input"));
                auto label = readText(hwmonEntry.path() / (prefix + "_label"));
                while (!label.empty() && std::isspace(static_cast<unsigned char>(label.back()))) label.pop_back();
                if (label.empty()) label = prefix;
                result.push_back({cleanName, label, *rpm});
            }
        }
        return result;
    }

    std::vector<HwmonTemperature> sampleHwmonTemperatures() const {
        std::vector<HwmonTemperature> result;
        std::error_code ec;
        const fs::path root("/sys/class/hwmon");
        if (!fs::exists(root, ec)) return result;
        for (const auto& hwmonEntry : fs::directory_iterator(root, ec)) {
            const auto hwmonNameRaw = readText(hwmonEntry.path() / "name");
            std::string hwmonName = hwmonNameRaw;
            while (!hwmonName.empty() && std::isspace(static_cast<unsigned char>(hwmonName.back()))) hwmonName.pop_back();
            for (const auto& file : fs::directory_iterator(hwmonEntry.path(), ec)) {
                const auto filename = file.path().filename().string();
                if (filename.rfind("temp", 0) != 0 || filename.find("_input") == std::string::npos) continue;
                const auto temperature = readScaled(file.path(), 1000.0);
                if (!std::isfinite(temperature)) continue;
                const auto prefix = filename.substr(0, filename.find("_input"));
                auto label = readText(hwmonEntry.path() / (prefix + "_label"));
                while (!label.empty() && std::isspace(static_cast<unsigned char>(label.back()))) label.pop_back();
                if (label.empty()) label = prefix;
                result.push_back({hwmonName, label, temperature});
            }
        }
        return result;
    }

    CpuSample sampleCpu() {
        CpuSample sample;
        const auto current = readCpuCounters();
        if (current.empty()) return sample;
        const auto previous = cpuPrevious_;
        cpuPrevious_ = current;
        sample.onlineCpus = current.size() > 0 ? static_cast<unsigned>(current.size() - 1) : 0;
        std::map<std::pair<int, int>, CpuCoreSample> groupedCores;
        std::map<std::string, CpuCounters> previousByName;
        for (const auto& cpu : previous) previousByName.emplace(cpu.name, cpu);
        for (const auto& cpu : current) {
            const auto found = previousByName.find(cpu.name);
            const auto* old = found == previousByName.end() ? nullptr : &found->second;
            const double usage = cpuCounterUsage(cpu, old);
            if (cpu.aggregate) { sample.usage = usage; continue; }
            auto& core = groupedCores[{cpu.packageId, cpu.coreId}];
            core.packageId = cpu.packageId;
            core.coreId = cpu.coreId;
            core.threads.push_back({cpu.cpuId, usage});
        }
        for (auto& [key, core] : groupedCores) {
            (void)key;
            std::sort(core.threads.begin(), core.threads.end(), [](const auto& a, const auto& b) { return a.cpuId < b.cpuId; });
            sample.cores.push_back(std::move(core));
        }

        const auto loads = readText("/proc/loadavg");
        std::istringstream loadStream(loads);
        loadStream >> sample.load1 >> sample.load5 >> sample.load15;

        double frequencyTotal = 0;
        unsigned frequencyCount = 0;
        std::error_code ec;
        for (const auto& entry : fs::directory_iterator("/sys/devices/system/cpu", ec)) {
            const auto name = entry.path().filename().string();
            if (name.rfind("cpu", 0) != 0 || name.size() < 4 || !std::isdigit(static_cast<unsigned char>(name[3]))) continue;
            const auto frequency = readU64(entry.path() / "cpufreq/scaling_cur_freq");
            if (frequency > 0) { frequencyTotal += frequency / 1000.0; ++frequencyCount; }
        }
        if (frequencyCount) sample.frequencyMhz = frequencyTotal / frequencyCount;
        sample.temperatureC = readCpuTemperature();
        return sample;
    }

    double readCpuTemperature() const {
        double best = std::numeric_limits<double>::quiet_NaN();
        int bestScore = -1;
        std::error_code ec;
        const fs::path root("/sys/class/hwmon");
        if (!fs::exists(root, ec)) return best;
        for (const auto& hwmon : fs::directory_iterator(root, ec)) {
            const auto name = readText(hwmon.path() / "name");
            if (name.find("amdgpu") != std::string::npos || name.find("nouveau") != std::string::npos || name.find("nvidia") != std::string::npos) continue;
            for (const auto& file : fs::directory_iterator(hwmon.path(), ec)) {
                const auto filename = file.path().filename().string();
                if (filename.find("_label") == std::string::npos || filename.rfind("temp", 0) != 0) continue;
                const auto label = readText(file.path());
                int score = -1;
                if (label.find("Tctl") != std::string::npos || label.find("Package id") != std::string::npos) score = 4;
                else if (label.find("CPU") != std::string::npos || label.find("Tdie") != std::string::npos) score = 3;
                else if (label.find("Core 0") != std::string::npos) score = 1;
                if (score < bestScore) continue;
                auto inputName = filename.substr(0, filename.size() - 6) + "_input";
                const auto raw = readU64(hwmon.path() / inputName);
                if (raw > 0) { best = raw / 1000.0; bestScore = score; }
            }
        }
        return best;
    }

    MemorySample sampleMemory() {
        MemorySample sample;
        std::map<std::string, std::uint64_t> values;
        std::ifstream input("/proc/meminfo");
        std::string line;
        while (std::getline(input, line)) {
            std::istringstream row(line);
            std::string key;
            std::uint64_t value = 0;
            if (!(row >> key >> value)) continue;
            if (!key.empty() && key.back() == ':') key.pop_back();
            values[key] = value;
        }
        sample.total = parseMemValue(values, "MemTotal");
        sample.available = parseMemValue(values, "MemAvailable");
        sample.meminfoAvailable = values.count("MemTotal") && values.count("MemAvailable") && sample.total > 0;
        sample.used = sample.total > sample.available ? sample.total - sample.available : 0;
        sample.free = parseMemValue(values, "MemFree");
        sample.buffers = parseMemValue(values, "Buffers");
        sample.reclaimable = parseMemValue(values, "SReclaimable");
        sample.slab = parseMemValue(values, "Slab");
        sample.shmem = parseMemValue(values, "Shmem");
        const auto pressure = readText("/proc/pressure/memory");
        const auto avg = pressure.find("some avg10=");
        if (avg != std::string::npos) {
            try { sample.psiSomeAvg10 = std::stod(pressure.substr(avg + 11)); } catch (...) {}
        }
        const auto cached = parseMemValue(values, "Cached");
        const auto reclaimable = parseMemValue(values, "SReclaimable");
        const auto shmem = parseMemValue(values, "Shmem");
        sample.cached = cached + reclaimable > shmem ? cached + reclaimable - shmem : 0;
        sample.swapTotal = parseMemValue(values, "SwapTotal");
        const auto swapFree = parseMemValue(values, "SwapFree");
        sample.swapUsed = sample.swapTotal > swapFree ? sample.swapTotal - swapFree : 0;
        std::ifstream vmstat("/proc/vmstat");
        std::string vmKey; std::uint64_t vmValue = 0, inPages = 0, outPages = 0;
        bool haveIn = false, haveOut = false;
        while (vmstat >> vmKey >> vmValue) {
            if (vmKey == "pswpin") { inPages = vmValue; haveIn = true; }
            else if (vmKey == "pswpout") { outPages = vmValue; haveOut = true; }
        }
        const auto now = Clock::now();
        const long pageSize = sysconf(_SC_PAGESIZE);
        if (haveIn && haveOut && pageSize > 0) {
            sample.swapIoAvailable = true;
            sample.swapInBytes = inPages * static_cast<std::uint64_t>(pageSize);
            sample.swapOutBytes = outPages * static_cast<std::uint64_t>(pageSize);
            const double elapsed = std::chrono::duration<double>(now - lastSwapSample_).count();
            if (swapBaseline_ && elapsed > 0 && inPages >= swapInPrevious_ && outPages >= swapOutPrevious_) {
                sample.swapInRate = (inPages - swapInPrevious_) * static_cast<double>(pageSize) / elapsed;
                sample.swapOutRate = (outPages - swapOutPrevious_) * static_cast<double>(pageSize) / elapsed;
            }
            swapInPrevious_ = inPages; swapOutPrevious_ = outPages; lastSwapSample_ = now; swapBaseline_ = true;
        }
        std::error_code ec;
        for (const auto& entry : fs::directory_iterator("/sys/block", ec)) {
            const auto name = entry.path().filename().string();
            if (name.rfind("zram", 0) != 0) continue;
            ++sample.zramCount;
            sample.zramSize += readU64(entry.path() / "disksize");
            std::uint64_t original = 0, compressed = 0, memory = 0;
            std::istringstream stats(readText(entry.path() / "mm_stat"));
            stats >> original >> compressed >> memory;
            sample.zramOriginal += original; sample.zramCompressed += compressed; sample.zramMemory += memory;
            const auto algorithm = readText(entry.path() / "comp_algorithm");
            const auto open = algorithm.find('['), close = algorithm.find(']');
            auto activeAlgorithm = (open != std::string::npos && close > open) ? algorithm.substr(open + 1, close - open - 1) : algorithm;
            while (!activeAlgorithm.empty() && std::isspace(static_cast<unsigned char>(activeAlgorithm.back()))) activeAlgorithm.pop_back();
            if (!sample.zramAlgorithm.empty()) sample.zramAlgorithm += ", ";
            sample.zramAlgorithm += name + ": " + activeAlgorithm;
        }
        return sample;
    }

    std::vector<GpuSample> sampleGpus(bool forceProbe = false, const fs::path& root = "/sys/class/drm") {
        const auto now = Clock::now();
        if (!nvml_->available() && (forceProbe || now - lastNvmlRetry_ >= std::chrono::seconds(30))) {
            nvml_ = std::make_unique<NvidiaNvml>();
            lastNvmlRetry_ = now;
        }
        std::vector<GpuSample> result = nvml_->sample();
        const bool nvmlHasDevices = !result.empty();
        std::error_code ec;
        if (!fs::exists(root, ec)) {
            if (!result.empty()) { gpuStatus_ = nvml_->status(); return result; }
            const auto nvidiaDevices = detectNvidiaPciDevices();
            gpuStatus_ = nvidiaDevices.empty()
                ? "No supported GPU telemetry provider found; /sys/class/drm is unavailable"
                : "NVIDIA PCI device(s) detected, but " + nvml_->status();
            appendNvidiaPciFallback(result, nvidiaDevices);
            return result;
        }
        for (const auto& entry : fs::directory_iterator(root, ec)) {
            const auto name = entry.path().filename().string();
            if (name.rfind("card", 0) != 0 || name.size() < 5 || !std::isdigit(static_cast<unsigned char>(name[4])) || name.find('-') != std::string::npos) continue;
            const auto device = entry.path() / "device";
            if (!fs::exists(device, ec)) continue;
            const auto vendor = readText(device / "vendor");
            const bool amd = vendor.find("0x1002") != std::string::npos;
            const bool intel = vendor.find("0x8086") != std::string::npos;
            const bool nvidia = vendor.find("0x10de") != std::string::npos;
            if (!amd && !intel && !nvidia) continue;
            // Do not double-count a device already represented by NVML.
            if (nvidia && nvmlHasDevices) continue;
            GpuSample gpu;
            gpu.name = name;
            gpu.vendor = amd ? "amd" : intel ? "intel" : "nvidia";
            const auto pciId = readText(device / "device");
            if (!pciId.empty()) {
                auto id = pciId;
                while (!id.empty() && std::isspace(static_cast<unsigned char>(id.back()))) id.pop_back();
                gpu.name += " · PCI " + id;
            }
            gpu.source = nvidia ? "DRM/sysfs · NVML unavailable" : "DRM/sysfs";
            const auto busy = readText(device / "gpu_busy_percent");
            try { if (!busy.empty()) gpu.usage = std::stod(busy); } catch (...) {}
            gpu.vramUsed = readU64Optional(device / "mem_info_vram_used");
            gpu.vramTotal = readU64Optional(device / "mem_info_vram_total");
            gpu.gttUsed = readU64Optional(device / "mem_info_gtt_used");
            gpu.gttTotal = readU64Optional(device / "mem_info_gtt_total");
            const auto clocks = readText(device / "pp_dpm_sclk");
            const auto star = clocks.find('*');
            if (star != std::string::npos) {
                const auto begin = clocks.rfind('\n', star);
                const auto line = clocks.substr(begin == std::string::npos ? 0 : begin + 1, star - (begin == std::string::npos ? 0 : begin + 1));
                const auto colon = line.find(':');
                const auto mhz = line.find("Mhz");
                if (colon != std::string::npos && mhz != std::string::npos) {
                    try { gpu.frequencyMhz = std::stod(line.substr(colon + 1, mhz - colon - 1)); } catch (...) {}
                }
            }
            const auto memClocks = readText(device / "pp_dpm_mclk");
            const auto memStar = memClocks.find('*');
            if (memStar != std::string::npos) {
                const auto begin = memClocks.rfind('\n', memStar);
                const auto line = memClocks.substr(begin == std::string::npos ? 0 : begin + 1, memStar - (begin == std::string::npos ? 0 : begin + 1));
                const auto colon = line.find(':');
                const auto mhz = line.find("Mhz");
                if (colon != std::string::npos && mhz != std::string::npos) {
                    try { gpu.memoryFrequencyMhz = std::stod(line.substr(colon + 1, mhz - colon - 1)); } catch (...) {}
                }
            }
            const auto hwmonRoot = device / "hwmon";
            if (fs::exists(hwmonRoot, ec)) {
                for (const auto& hwmon : fs::directory_iterator(hwmonRoot, ec)) {
                    const auto raw = readU64(hwmon.path() / "temp1_input");
                    if (raw > 0) gpu.temperatureC = raw / 1000.0;
                    const auto power = readU64Optional(hwmon.path() / "power1_average");
                    const auto instantaneous = readU64Optional(hwmon.path() / "power1_input");
                    if (power) gpu.powerW = *power / 1000000.0;
                    else if (instantaneous) gpu.powerW = *instantaneous / 1000000.0;
                    break;
                }
            }
            result.push_back(gpu);
        }
        if (!nvmlHasDevices) appendNvidiaPciFallback(result, detectNvidiaPciDevices());
        if (!result.empty()) {
            gpuStatus_ = "GPU devices detected: " + std::to_string(result.size()) + " device(s); " + nvml_->status();
        } else {
            const auto nvidiaDevices = detectNvidiaPciDevices();
            if (!nvidiaDevices.empty()) {
                gpuStatus_ = std::to_string(nvidiaDevices.size()) + " NVIDIA PCI device(s) detected (";
                for (std::size_t i = 0; i < nvidiaDevices.size(); ++i) {
                    if (i) gpuStatus_ += ", ";
                    gpuStatus_ += nvidiaDevices[i];
                }
                gpuStatus_ += "), but " + nvml_->status();
            } else {
                gpuStatus_ = "No supported GPU telemetry provider found; " + nvml_->status();
            }
        }
        return result;
    }

    std::vector<DiskSample> sampleDisks(double elapsed) {
        std::map<std::string, DiskCounter> current;
        std::ifstream input("/proc/diskstats");
        std::string line;
        while (std::getline(input, line)) {
            std::istringstream row(line);
            unsigned major = 0, minor = 0;
            std::string name;
            if (!(row >> major >> minor >> name)) continue;
            std::array<std::uint64_t, 11> fields{};
            std::size_t count = 0;
            while (count < fields.size() && row >> fields[count]) ++count;
            if (count < 10) continue;
            const auto sysDevice = fs::path("/sys/block") / name / "device";
            std::error_code ec;
            if (!fs::exists(sysDevice, ec)) continue; // Ignore virtual devices and block layers.
            DiskCounter counter;
            counter.reads = fields[0]; counter.sectorsRead = fields[2];
            counter.writes = fields[4]; counter.sectorsWritten = fields[6];
            counter.ioMs = fields[9];
            current[name] = counter;
        }
        std::vector<DiskSample> result;
        const auto sampledAt = Clock::now();
        const bool refreshTemperature = lastDiskTemperatureSample_.time_since_epoch().count() == 0 || sampledAt - lastDiskTemperatureSample_ >= std::chrono::seconds(5);
        if (refreshTemperature) lastDiskTemperatureSample_ = sampledAt;
        for (const auto& [diskName, now] : current) {
            DiskSample sample; sample.name = diskName;
            if (refreshTemperature || !diskTemperatures_.contains(diskName))
                diskTemperatures_[diskName] = readDiskTemperature(fs::path("/sys/block") / diskName);
            sample.temperatureC = diskTemperatures_[diskName];
            const auto old = diskPrevious_.find(diskName);
            if (old != diskPrevious_.end()) {
                const auto& before = old->second;
                sample.readBytesPerSecond = monotonicRate(now.sectorsRead, before.sectorsRead, elapsed, kSectorBytes);
                sample.writeBytesPerSecond = monotonicRate(now.sectorsWritten, before.sectorsWritten, elapsed, kSectorBytes);
                sample.readIops = monotonicRate(now.reads, before.reads, elapsed);
                sample.writeIops = monotonicRate(now.writes, before.writes, elapsed);
                const auto utilization = monotonicRate(now.ioMs, before.ioMs, elapsed, 0.1);
                if (std::isfinite(utilization)) sample.utilization = std::clamp(utilization, 0.0, 100.0);
            }
            result.push_back(sample);
        }
        for (auto it = diskTemperatures_.begin(); it != diskTemperatures_.end();) {
            if (!current.contains(it->first)) it = diskTemperatures_.erase(it); else ++it;
        }
        diskPrevious_ = std::move(current);
        return result;
    }

    std::vector<NetSample> sampleNetworks(double elapsed) {
        std::map<std::string, NetCounter> current;
        std::error_code ec;
        const fs::path root("/sys/class/net");
        if (fs::exists(root, ec)) {
            for (const auto& entry : fs::directory_iterator(root, ec)) {
                const auto name = entry.path().filename().string();
                if (name == "lo" || !fs::exists(entry.path() / "device", ec)) continue;
                NetCounter counter;
                const auto rx = readU64Optional(entry.path() / "statistics/rx_bytes");
                const auto tx = readU64Optional(entry.path() / "statistics/tx_bytes");
                if (!rx || !tx) continue;
                counter.rx = *rx; counter.tx = *tx;
                current[name] = counter;
            }
        }
        std::map<std::string, std::vector<std::string>> addresses;
        ifaddrs* interfaces = nullptr;
        if (getifaddrs(&interfaces) == 0) {
            for (auto* iface = interfaces; iface; iface = iface->ifa_next) {
                if (!iface->ifa_addr || !iface->ifa_name) continue;
                const int family = iface->ifa_addr->sa_family;
                const void* address = nullptr;
                if (family == AF_INET) address = &reinterpret_cast<sockaddr_in*>(iface->ifa_addr)->sin_addr;
                else if (family == AF_INET6) address = &reinterpret_cast<sockaddr_in6*>(iface->ifa_addr)->sin6_addr;
                if (!address) continue;
                char text[INET6_ADDRSTRLEN]{};
                if (inet_ntop(family, address, text, sizeof(text))) addresses[iface->ifa_name].push_back(text);
            }
            freeifaddrs(interfaces);
        }
        std::vector<NetSample> result;
        for (const auto& [ifName, now] : current) {
            NetSample sample; sample.name = ifName; sample.rxBytes = now.rx; sample.txBytes = now.tx;
            const auto path = root / ifName;
            sample.type = (fs::exists(path / "wireless", ec) || fs::exists(path / "phy80211", ec)) ? "Wi-Fi" : "Ethernet/other";
            sample.state = readText(path / "operstate"); sample.mac = readText(path / "address");
            while (!sample.state.empty() && std::isspace(static_cast<unsigned char>(sample.state.back()))) sample.state.pop_back();
            while (!sample.mac.empty() && std::isspace(static_cast<unsigned char>(sample.mac.back()))) sample.mac.pop_back();
            sample.linkSpeedMbps = readScaled(path / "speed", 1.0);
            if (!(sample.linkSpeedMbps > 0)) sample.linkSpeedMbps = std::numeric_limits<double>::quiet_NaN();
            sample.addresses = addresses[ifName];
            const auto old = networkPrevious_.find(ifName);
            if (old != networkPrevious_.end()) {
                sample.rxBytesPerSecond = monotonicRate(now.rx, old->second.rx, elapsed);
                sample.txBytesPerSecond = monotonicRate(now.tx, old->second.tx, elapsed);
            }
            result.push_back(sample);
        }
        networkPrevious_ = std::move(current);
        return result;
    }

    static std::string fansJson(const std::vector<FanSample>& fans) {
        std::ostringstream out; out << '[';
        for (std::size_t i = 0; i < fans.size(); ++i) {
            if (i) out << ',';
            out << "{\"hwmon\":\"" << jsonEscape(fans[i].hwmon)
                << "\",\"label\":\"" << jsonEscape(fans[i].label)
                << "\",\"rpm\":" << fans[i].rpm << '}';
        }
        out << ']'; return out.str();
    }

    static std::string hwmonJson(const std::vector<HwmonTemperature>& sensors) {
        std::ostringstream out; out << '[';
        for (std::size_t i = 0; i < sensors.size(); ++i) {
            if (i) out << ',';
            out << "{\"hwmon\":\"" << jsonEscape(sensors[i].hwmon)
                << "\",\"label\":\"" << jsonEscape(sensors[i].label)
                << "\",\"temperatureC\":" << jsonNumber(sensors[i].temperatureC) << '}';
        }
        out << ']'; return out.str();
    }

    static std::string cpuJson(const CpuSample& sample) {
        std::ostringstream out;
        out << "{\"usage\":" << jsonNumber(sample.usage)
            << ",\"frequencyMhz\":" << jsonNumber(sample.frequencyMhz)
            << ",\"temperatureC\":" << jsonNumber(sample.temperatureC)
            << ",\"load1\":" << jsonNumber(sample.load1)
            << ",\"load5\":" << jsonNumber(sample.load5)
            << ",\"load15\":" << jsonNumber(sample.load15)
            << ",\"onlineCpus\":" << sample.onlineCpus << ",\"cores\":[";
        for (std::size_t i = 0; i < sample.cores.size(); ++i) {
            if (i) out << ',';
            const auto& core = sample.cores[i];
            out << "{\"packageId\":" << core.packageId << ",\"coreId\":" << core.coreId << ",\"threads\":[";
            for (std::size_t thread = 0; thread < core.threads.size(); ++thread) {
                if (thread) out << ',';
                out << "{\"cpuId\":" << core.threads[thread].cpuId << ",\"usage\":" << jsonNumber(core.threads[thread].usage) << '}';
            }
            out << "]}";
        }
        out << "]}";
        return out.str();
    }

    static std::string memoryJson(const MemorySample& sample) {
        std::ostringstream out;
        const auto mem = [&sample](std::uint64_t v) { return sample.meminfoAvailable ? std::to_string(v) : std::string("null"); };
        out << "{\"totalBytes\":" << mem(sample.total) << ",\"usedBytes\":" << mem(sample.used)
            << ",\"availableBytes\":" << mem(sample.available) << ",\"cachedBytes\":" << mem(sample.cached)
            << ",\"freeBytes\":" << mem(sample.free) << ",\"buffersBytes\":" << mem(sample.buffers)
            << ",\"reclaimableBytes\":" << mem(sample.reclaimable) << ",\"slabBytes\":" << mem(sample.slab)
            << ",\"shmemBytes\":" << mem(sample.shmem) << ",\"psiSomeAvg10\":" << jsonNumber(sample.psiSomeAvg10)
            << ",\"zramCount\":" << sample.zramCount << ",\"zramSizeBytes\":" << sample.zramSize
            << ",\"swapTotalBytes\":" << mem(sample.swapTotal) << ",\"swapUsedBytes\":" << mem(sample.swapUsed)
            << ",\"swapIoAvailable\":" << (sample.swapIoAvailable ? "true" : "false")
            << ",\"swapInBytes\":" << sample.swapInBytes << ",\"swapOutBytes\":" << sample.swapOutBytes
            << ",\"swapInBytesPerSecond\":" << jsonNumber(sample.swapInRate) << ",\"swapOutBytesPerSecond\":" << jsonNumber(sample.swapOutRate)
            << ",\"zramOriginalBytes\":" << sample.zramOriginal << ",\"zramCompressedBytes\":" << sample.zramCompressed
            << ",\"zramMemoryBytes\":" << sample.zramMemory << ",\"zramAlgorithm\":\"" << jsonEscape(sample.zramAlgorithm) << "\"}";
        return out.str();
    }

    static std::string gpuJson(const std::vector<GpuSample>& gpus) {
        std::ostringstream out; out << '[';
        for (std::size_t i = 0; i < gpus.size(); ++i) {
            if (i) out << ',';
            const auto& gpu = gpus[i];
            out << "{\"name\":\"" << jsonEscape(gpu.name) << "\",\"vendor\":\"" << jsonEscape(gpu.vendor)
                << "\",\"usage\":" << jsonNumber(gpu.usage) << ",\"temperatureC\":" << jsonNumber(gpu.temperatureC)
                << ",\"frequencyMhz\":" << jsonNumber(gpu.frequencyMhz) << ",\"powerW\":" << jsonNumber(gpu.powerW)
                << ",\"memoryUsage\":" << jsonNumber(gpu.memoryUsage) << ",\"memoryFrequencyMhz\":" << jsonNumber(gpu.memoryFrequencyMhz)
                << ",\"vramUsedBytes\":" << jsonOptional(gpu.vramUsed) << ",\"vramTotalBytes\":" << jsonOptional(gpu.vramTotal)
                << ",\"gttUsedBytes\":" << jsonOptional(gpu.gttUsed) << ",\"gttTotalBytes\":" << jsonOptional(gpu.gttTotal)
                << ",\"source\":\"" << jsonEscape(gpu.source) << "\"}";
        }
        out << ']'; return out.str();
    }

    static std::string diskJson(const std::vector<DiskSample>& disks) {
        std::ostringstream out; out << '[';
        for (std::size_t i = 0; i < disks.size(); ++i) {
            if (i) out << ',';
            const auto& disk = disks[i];
            out << "{\"name\":\"" << jsonEscape(disk.name) << "\",\"readBytesPerSecond\":" << jsonNumber(disk.readBytesPerSecond)
                << ",\"writeBytesPerSecond\":" << jsonNumber(disk.writeBytesPerSecond)
                << ",\"readIops\":" << jsonNumber(disk.readIops) << ",\"writeIops\":" << jsonNumber(disk.writeIops)
                << ",\"utilization\":" << jsonNumber(disk.utilization)
                << ",\"temperatureC\":" << jsonNumber(disk.temperatureC) << '}';
        }
        out << ']'; return out.str();
    }

    static std::string networkJson(const std::vector<NetSample>& networks) {
        std::ostringstream out; out << '[';
        for (std::size_t i = 0; i < networks.size(); ++i) {
            if (i) out << ',';
            const auto& net = networks[i];
            out << "{\"name\":\"" << jsonEscape(net.name) << "\",\"rxBytesPerSecond\":" << jsonNumber(net.rxBytesPerSecond)
                << ",\"txBytesPerSecond\":" << jsonNumber(net.txBytesPerSecond)
                << ",\"rxBytes\":" << net.rxBytes << ",\"txBytes\":" << net.txBytes
                << ",\"type\":\"" << jsonEscape(net.type) << "\",\"state\":\"" << jsonEscape(net.state)
                << "\",\"mac\":\"" << jsonEscape(net.mac) << "\",\"linkSpeedMbps\":" << jsonNumber(net.linkSpeedMbps) << ",\"addresses\":[";
            for (std::size_t a = 0; a < net.addresses.size(); ++a) {
                if (a) out << ',';
                out << '"' << jsonEscape(net.addresses[a]) << '"';
            }
            out << "]}";
        }
        out << ']'; return out.str();
    }

    std::map<std::string, BatteryDetail> batteryCache_;
    PowerDetails powerDetails_;
    Clock::time_point lastPowerSample_{};
    Clock::time_point lastPowerRateSample_{};
    bool swapBaseline_ = false;
    std::uint64_t swapInPrevious_ = 0, swapOutPrevious_ = 0;
    Clock::time_point lastSwapSample_ = Clock::now();
    std::vector<CpuCounters> cpuPrevious_;
    std::map<std::string, InspectorState> inspectorStates_;
    std::vector<FanSample> fans_;
    std::vector<HwmonTemperature> hwmonTemperatures_;
    Clock::time_point lastFanSample_ = Clock::now();
    Clock::time_point lastHwmonSample_ = Clock::now();
    std::map<std::string, DiskCounter> diskPrevious_;
    std::map<std::string, double> diskTemperatures_;
    Clock::time_point lastDiskTemperatureSample_{};
    std::map<std::string, NetCounter> networkPrevious_;
    Clock::time_point lastDiskSample_ = Clock::now();
    Clock::time_point lastNetworkSample_ = Clock::now();
    std::unique_ptr<NvidiaNvml> nvml_;
    Clock::time_point lastNvmlRetry_ = Clock::now();
    std::string gpuStatus_ = "GPU provider has not been probed yet";
    std::string keyboardLayout_;
    bool uefiSetupSupported_ = false;
    Clock::time_point lastKeyboardCheck_;
};

} // namespace

int main(int argc, char** argv) {
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);

    if (argc > 1 && std::string_view(argv[1]) == "--gpu-probe") {
        NvidiaNvml nvml;
        const auto devices = detectNvidiaPciDevices();
        std::cout << "NVML: " << nvml.status() << "\n";
        std::cout << "NVIDIA PCI display/3D devices: " << devices.size() << "\n";
        for (const auto& device : devices) std::cout << "  " << device << "\n";
        const std::array<const char*, 4> paths = {
            "/run/opengl-driver/lib/libnvidia-ml.so.1",
            "/run/opengl-driver/lib/libnvidia-ml.so",
            "/run/current-system/sw/lib/libnvidia-ml.so.1",
            "/run/current-system/sw/lib/libnvidia-ml.so"
        };
        for (const char* path : paths) {
            std::error_code ec;
            const bool present = fs::exists(path, ec);
            std::cout << (present ? "[present] " : "[missing] ") << path;
            if (present) {
                const auto target = fs::weakly_canonical(path, ec);
                if (!ec) std::cout << " -> " << target.string();
            }
            std::cout << "\n";
        }
        return nvml.available() ? 0 : 2;
    }

    Collector collector;
    // Emit an immediate complete snapshot so the bar has useful data at startup.
    std::cout << collector.collect() << std::endl;

    auto nextTick = Clock::now() + kSampleInterval;
    std::string pending;
    while (true) {
        const auto now = Clock::now();
        const auto remaining = now < nextTick
            ? std::chrono::duration_cast<std::chrono::milliseconds>(nextTick - now).count()
            : 0;
        pollfd descriptor{STDIN_FILENO, POLLIN, 0};
        const int ready = poll(&descriptor, 1, static_cast<int>(remaining));
        if (ready > 0 && (descriptor.revents & POLLIN)) {
            char buffer[256];
            const auto bytes = ::read(STDIN_FILENO, buffer, sizeof(buffer));
            if (bytes <= 0) break;
            pending.append(buffer, static_cast<std::size_t>(bytes));
            std::size_t newline = 0;
            while ((newline = pending.find('\n')) != std::string::npos) {
                const auto command = pending.substr(0, newline);
                pending.erase(0, newline + 1);
                if (command.rfind("refresh", 0) == 0) {
                    auto group = command.size() > 8 ? command.substr(8) : "all";
                    if (group.empty()) group = "all";
                    if (group != "cpu" && group != "gpu" && group != "vram" && group != "ram" && group != "disk" && group != "network" && group != "battery" && group != "keyboard") group = "all";
                    std::cout << collector.collect(group) << std::endl;
                } else if (command == "switch keyboard") {
                    const auto reply = hyprlandRequest("/switchxkblayout all next");
                    if (reply == "ok" || reply == "ok\n") std::cout << collector.collect("keyboard") << std::endl;
                    else std::cerr << "Keyboard layout switch failed: " << (reply.empty() ? "no Hyprland response" : reply) << std::endl;
                } else if (command.rfind("pss ", 0) == 0) {
                    const auto slot = command.substr(4);
                    if (!slot.empty() && slot.find_first_of(" \t/\\") == std::string::npos) {
                        collector.requestInspectorPss(slot);
                        std::cout << collector.collect("inspectors") << std::endl;
                    }
                } else if (command.rfind("inspect ", 0) == 0) {
                    std::istringstream args(command.substr(8));
                    std::string slot;
                    int pid = 0;
                    if (args >> slot >> pid && pid > 0 && slot.find_first_of(" \t/\\") == std::string::npos) {
                        collector.setInspector(slot, pid);
                        std::cout << collector.collect("inspectors") << std::endl;
                    }
                } else if (command.rfind("uninspect ", 0) == 0) {
                    const auto slot = command.substr(10);
                    collector.clearInspector(slot);
                    std::cout << collector.collect("inspectors") << std::endl;
                }
                if (command == "quit") return 0;
            }
        }
        if (ready > 0 && !(descriptor.revents & POLLIN) && (descriptor.revents & (POLLHUP | POLLERR | POLLNVAL))) break;
        if (Clock::now() >= nextTick) {
            std::cout << collector.collect() << std::endl;
            nextTick = Clock::now() + kSampleInterval;
        }
    }
    return 0;
}
