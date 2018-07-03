#include "logger.h"
#include "settingsmanager.h"

PING_LOGGING_CATEGORY(SETTINGSMANAGER, "ping.settingsmanager")

SettingsManager::SettingsManager()
    : _settings("Blue Robotics Inc.", "Ping Viewer")
{
    //TODO: reset settings if new version
    if(_settings.contains("reset")) {
        bool reset = _settings.value("reset").toBool();
        if(reset) {
            _settings.clear();
        }
    }
}

QVariant SettingsManager::value(QString& settingName)
{
    // Check if settings for that exist and get it, otherwise return default (0);
    if(_settings.contains(settingName)) {
        return _settings.value(settingName).toInt();
    }

    qCWarning(SETTINGSMANAGER) << \
                               QStringLiteral("Settings for %2 does not exist.").arg(settingName);
    return 0;
}

void SettingsManager::set(QString& settingName, QVariant& value)
{
    // Check if our map of models does have anything about it
    if(!_settings.contains(settingName)) {
        qCDebug(SETTINGSMANAGER) << QStringLiteral("New value in %1:").arg(settingName) << value;
    } else {
        qCDebug(SETTINGSMANAGER) << QStringLiteral("In %1:").arg(settingName) << value;
    }
    _settings.setValue(settingName, value);
}

SettingsManager* SettingsManager::self()
{
    static SettingsManager* self = new SettingsManager();
    return self;
}

SettingsManager::~SettingsManager()
{
}