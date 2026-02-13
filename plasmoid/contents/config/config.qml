import QtQuick
import org.kde.plasma.configuration

ConfigModel {
	ConfigCategory {
		name: i18n("General")
		icon: "preferences-desktop"
		source: "config/general.qml"
	}

	ConfigCategory {
		name: i18n("Fetch")
		icon: "edit-download"
		source: "config/fetch.qml"
	}

	ConfigCategory {
		name: i18n("Stack")
		icon: "office-chart-area-stacked"
		source: "config/stack.qml"
	}
}
