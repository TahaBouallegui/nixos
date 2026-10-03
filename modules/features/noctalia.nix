{
  self,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = pkgs.noctalia-shell.overrideAttrs {
          name = "noctalia";
        };
        env = {
          "NOCTALIA_CACHE_DIR" = "/tmp/noctalia-cache/";
        };
        colors = {
          mError = "#fb4934";
          mHover = "#83a598";
          mOnError = "#282828";
          mOnHover = "#282828";
          mOnPrimary = "#282828";
          mOnSecondary = "#282828";
          mOnSurface = "#fbf1c7";
          mOnSurfaceVariant = "#ebdbb2";
          mOnTertiary = "#282828";
          mOutline = "#57514e";
          mPrimary = "#b8bb26";
          mSecondary = "#fabd2f";
          mShadow = "#282828";
          mSurface = "#282828";
          mSurfaceVariant = "#3c3836";
          mTertiary = "#83a598";
        };

        settings = {
          appLauncher = {
            autoPasteClipboard = false;
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWrapText = true;
            customLaunchPrefix = "";
            customLaunchPrefixEnabled = false;
            density = "default";
            enableClipPreview = true;
            enableClipboardChips = true;
            enableClipboardHistory = false;
            enableClipboardSmartIcons = true;
            enableSessionSearch = true;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            iconMode = "tabler";
            ignoreMouseInput = false;
            overviewLayer = false;
            pinnedApps = [ ];
            position = "center";
            screenshotAnnotationTool = "";
            showCategories = true;
            showIconBackground = false;
            sortByMostUsed = true;
            terminalCommand = "kitty -e";
            viewMode = "list";
          };
          audio = {
            mprisBlacklist = [ ];
            preferredPlayer = "";
            spectrumFrameRate = 30;
            spectrumMirrored = true;
            visualizerType = "linear";
            volumeFeedback = false;
            volumeFeedbackSoundFile = "";
            volumeOverdrive = false;
            volumeStep = 5;
          };
          bar = {
            autoHideDelay = 500;
            autoShowDelay = 150;
            backgroundOpacity = 0.93;
            barType = "simple";
            capsuleColorKey = "none";
            capsuleOpacity = 1;
            contentPadding = 2;
            density = "comfortable";
            displayMode = "always_visible";
            enableExclusionZoneInset = true;
            fontScale = 1;
            frameRadius = 12;
            frameThickness = 8;
            hideOnOverview = false;
            marginHorizontal = 5;
            marginVertical = 5;
            middleClickAction = "none";
            middleClickCommand = "";
            middleClickFollowMouse = false;
            monitors = [ ];
            mouseWheelAction = "none";
            mouseWheelWrap = true;
            outerCorners = true;
            position = "left";
            reverseScroll = false;
            rightClickAction = "controlCenter";
            rightClickCommand = "";
            rightClickFollowMouse = true;
            screenOverrides = [ ];
            showCapsule = false;
            showOnWorkspaceSwitch = true;
            showOutline = false;
            useSeparateOpacity = false;
            widgetSpacing = 6;
            widgets = {
              center = [
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  followFocusedScreen = false;
                  fontWeight = "bold";
                  groupedBorderOpacity = 1;
                  hideUnoccupied = true;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "none";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                  showApplications = false;
                  showApplicationsHover = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = true;
                  unfocusedIconsOpacity = 1;
                }
              ];
              left = [
                {
                  colorizeDistroLogo = true;
                  colorizeSystemIcon = "tertiary";
                  colorizeSystemText = "none";
                  customIconPath = "";
                  enableColorization = true;
                  icon = "noctalia";
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                {
                  compactMode = true;
                  diskPath = "/";
                  iconColor = "none";
                  id = "SystemMonitor";
                  showCpuCores = false;
                  showCpuFreq = false;
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskAvailable = false;
                  showDiskUsage = false;
                  showDiskUsageAsPercent = false;
                  showGpuTemp = false;
                  showLoadAverage = false;
                  showMemoryAsPercent = false;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  showSwapUsage = false;
                  textColor = "none";
                  useMonospaceFont = true;
                  usePadding = false;
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "VPN";
                  textColor = "none";
                }
              ];
              right = [
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = false;
                  iconColor = "none";
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  iconColor = "none";
                  id = "PowerProfile";
                }
                {
                  displayMode = "alwaysHide";
                  iconColor = "none";
                  id = "Volume";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                  textColor = "none";
                }
                {
                  deviceNativePath = "";
                  displayMode = "alwaysShow";
                  hideIfIdle = false;
                  hideIfNotDetected = true;
                  id = "Battery";
                  showNoctaliaPerformance = false;
                  showPowerProfiles = false;
                }
                {
                  clockColor = "none";
                  customFont = "";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm - dd MM";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = false;
                }
                {
                  blacklist = [ ];
                  chevronColor = "none";
                  colorizeIcons = false;
                  drawerEnabled = true;
                  hidePassive = false;
                  id = "Tray";
                  pinned = [ ];
                }
              ];
            };
          };
          brightness = {
            backlightDeviceMappings = [ ];
            brightnessStep = 5;
            enableDdcSupport = false;
            enforceMinimum = true;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };
          colorSchemes = {
            darkMode = true;
            generationMethod = "tonal-spot";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            monitorForColors = "";
            predefinedScheme = "Noctalia (default)";
            schedulingMode = "off";
            syncGsettings = true;
            useWallpaperColors = false;
          };
          controlCenter = {
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = true;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
            diskPath = "/";
            position = "close_to_bar_button";
            shortcuts = {
              left = [
                { id = "Network"; }
                { id = "Bluetooth"; }
              ];
              right = [
                { id = "Notifications"; }
                { id = "PowerProfile"; }
              ];
            };
          };
          desktopWidgets = {
            enabled = false;
            gridSnap = false;
            gridSnapScale = false;
            monitorWidgets = [
              {
                name = "HDMI-A-1";
                widgets = [
                  {
                    hideMode = "visible";
                    id = "MediaPlayer";
                    showBackground = true;
                    showButtons = true;
                    visualizerType = "linear";
                    x = 100;
                    y = 200;
                  }
                ];
              }
            ];
            overviewEnabled = true;
          };
          dock = {
            animationSpeed = 1;
            backgroundOpacity = 1;
            colorizeIcons = false;
            deadOpacity = 0.6;
            displayMode = "auto_hide";
            dockType = "floating";
            enabled = false;
            floatingRatio = 1;
            groupApps = false;
            groupClickAction = "cycle";
            groupContextMenuMode = "extended";
            groupIndicatorStyle = "dots";
            inactiveIndicators = false;
            indicatorColor = "primary";
            indicatorOpacity = 0.6;
            indicatorThickness = 3;
            launcherIcon = "";
            launcherIconColor = "none";
            launcherPosition = "end";
            launcherUseDistroLogo = false;
            monitors = [ ];
            onlySameOutput = true;
            pinnedApps = [ ];
            pinnedStatic = false;
            position = "bottom";
            showDockIndicator = false;
            showLauncherIcon = false;
            sitOnFrame = false;
            size = 1;
          };
          general = {
            allowPanelsOnScreenWithoutBar = true;
            allowPasswordWithFprintd = false;
            animationDisabled = false;
            animationSpeed = 1;
            autoStartAuth = false;
            avatarImage = ../../modules/features/wallpaper/gruv.jpg;
            boxRadiusRatio = 1;
            clockFormat = "hh\\nmm";
            clockStyle = "custom";
            compactLockScreen = false;
            dimmerOpacity = 0.15;
            enableBlurBehind = true;
            enableLockScreenCountdown = true;
            enableLockScreenMediaControls = false;
            enableShadows = true;
            forceBlackScreenCorners = false;
            iRadiusRatio = 1;
            keybinds = {
              keyDown = [ "Down" ];
              keyEnter = [
                "Return"
                "Enter"
              ];
              keyEscape = [ "Esc" ];
              keyLeft = [ "Left" ];
              keyRemove = [ "Del" ];
              keyRight = [ "Right" ];
              keyUp = [ "Up" ];
            };
            language = "";
            lockOnSuspend = true;
            lockScreenAnimations = false;
            lockScreenBlur = 0;
            lockScreenCountdownDuration = 10000;
            lockScreenMonitors = [ ];
            lockScreenTint = 0;
            passwordChars = false;
            radiusRatio = 1;
            reverseScroll = false;
            scaleRatio = 1;
            screenRadiusRatio = 1;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            showChangelogOnStartup = true;
            showHibernateOnLockScreen = false;
            showScreenCorners = false;
            showSessionButtonsOnLockScreen = true;
            smoothScrollEnabled = true;
            telemetryEnabled = false;
          };
          hooks = {
            colorGeneration = "";
            darkModeChange = "";
            enabled = false;
            performanceModeDisabled = "";
            performanceModeEnabled = "";
            screenLock = "";
            screenUnlock = "";
            session = "";
            startup = "";
            wallpaperChange = "";
          };
          idle = {
            customCommands = "[]";
            enabled = true;
            fadeDuration = 5;
            lockCommand = "";
            lockTimeout = 660;
            resumeLockCommand = "";
            resumeScreenOffCommand = "";
            resumeSuspendCommand = "";
            screenOffCommand = "";
            screenOffTimeout = 600;
            suspendCommand = "";
            suspendTimeout = 1800;
          };
          location = {
            analogClockInCalendar = false;
            autoLocate = false;
            firstDayOfWeek = -1;
            hideWeatherCityName = false;
            hideWeatherTimezone = false;
            name = "Lille, France";
            showCalendarEvents = true;
            showCalendarWeather = true;
            showWeekNumberInCalendar = true;
            use12hourFormat = false;
            useFahrenheit = false;
            weatherEnabled = true;
            weatherShowEffects = true;
            weatherTaliaMascotAlways = true;
          };
          network = {
            bluetoothAutoConnect = true;
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
            bluetoothRssiPollIntervalMs = 60000;
            bluetoothRssiPollingEnabled = false;
            disableDiscoverability = false;
            networkPanelView = "wifi";
            wifiDetailsViewMode = "grid";
          };
          nightLight = {
            autoSchedule = true;
            dayTemp = "6500";
            enabled = false;
            forced = false;
            manualSunrise = "06:30";
            manualSunset = "18:30";
            nightTemp = "4000";
          };
          noctaliaPerformance = {
            disableDesktopWidgets = true;
            disableWallpaper = true;
          };
          notifications = {
            backgroundOpacity = 1;
            clearDismissed = true;
            criticalUrgencyDuration = 15;
            density = "default";
            enableBatteryToast = true;
            enableKeyboardLayoutToast = true;
            enableMarkdown = false;
            enableMediaToast = false;
            enabled = true;
            location = "top_right";
            lowUrgencyDuration = 8;
            monitors = [ ];
            normalUrgencyDuration = 8;
            overlayLayer = true;
            respectExpireTimeout = false;
            saveToHistory = {
              critical = true;
              low = true;
              normal = true;
            };
            sounds = {
              criticalSoundFile = "";
              enabled = false;
              excludedApps = "discord,firefox,chrome,chromium,edge";
              lowSoundFile = "";
              normalSoundFile = "";
              separateSounds = false;
              volume = 0.5;
            };
          };
          osd = {
            autoHideMs = 3000;
            backgroundOpacity = 1;
            enabled = true;
            enabledTypes = [
              0
              1
              2
              4
            ];
            location = "bottom";
            monitors = [ ];
            overlayLayer = true;
          };
          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
          };
          sessionMenu = {
            countdownDuration = 10000;
            enableCountdown = true;
            largeButtonsLayout = "grid";
            largeButtonsStyle = true;
            position = "center";
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "1";
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "2";
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "3";
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "4";
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "5";
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "6";
              }
              {
                action = "userspaceReboot";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
              {
                action = "rebootToUefi";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
            ];
            showHeader = true;
            showKeybinds = true;
          };
          settingsVersion = 59;
          systemMonitor = {
            batteryCriticalThreshold = 5;
            batteryWarningThreshold = 20;
            cpuCriticalThreshold = 90;
            cpuWarningThreshold = 80;
            criticalColor = "";
            diskAvailCriticalThreshold = 10;
            diskAvailWarningThreshold = 20;
            diskCriticalThreshold = 90;
            diskWarningThreshold = 80;
            enableDgpuMonitoring = false;
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
            gpuCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            memCriticalThreshold = 90;
            memWarningThreshold = 80;
            swapCriticalThreshold = 90;
            swapWarningThreshold = 80;
            tempCriticalThreshold = 90;
            tempWarningThreshold = 80;
            useCustomColors = false;
            warningColor = "";
          };
          templates = {
            activeTemplates = [ ];
            enableUserTheming = false;
          };
          ui = {
            boxBorderEnabled = false;
            fontDefault = "Sans Serif";
            fontDefaultScale = 1;
            fontFixed = "monospace";
            fontFixedScale = 1;
            panelBackgroundOpacity = 1;
            panelsAttachedToBar = true;
            scrollbarAlwaysVisible = true;
            settingsPanelMode = "attached";
            settingsPanelSideBarCardStyle = false;
            tooltipsEnabled = true;
            translucentWidgets = false;
          };
          wallpaper = {
            automationEnabled = false;
            directory = "/home/atb/Pictures/Wallpapers";
            enableMultiMonitorDirectories = false;
            enabled = false;
            favorites = [ ];
            fillColor = "#000000";
            fillMode = "crop";
            hideWallpaperFilenames = false;
            linkLightAndDarkWallpapers = true;
            monitorDirectories = [ ];
            overviewBlur = 0.4;
            overviewEnabled = false;
            overviewTint = 0.6;
            panelPosition = "follow_bar";
            randomIntervalSec = 300;
            setWallpaperOnAllMonitors = true;
            showHiddenFiles = false;
            skipStartupTransition = false;
            solidColor = "#1a1a2e";
            sortOrder = "name";
            transitionDuration = 1500;
            transitionEdgeSmoothness = 0.05;
            transitionType = [
              "fade"
              "disc"
              "stripes"
              "wipe"
              "pixelate"
              "honeycomb"
            ];
            useOriginalImages = false;
            useSolidColor = false;
            useWallhaven = false;
            viewMode = "single";
            wallhavenApiKey = "";
            wallhavenCategories = "111";
            wallhavenOrder = "desc";
            wallhavenPurity = "100";
            wallhavenQuery = "";
            wallhavenRatios = "";
            wallhavenResolutionHeight = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenSorting = "relevance";
            wallpaperChangeMode = "random";
          };
        };
      };
    };
}
