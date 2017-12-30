import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import QtDataVisualization 1.2
import "."

Item {
    id: waterfall
    visible: true
    width: 500
    height: 500

    Item {
        id: surfaceView
        width: waterfall.width
        height: waterfall.height
        anchors.top: waterfall.top
        anchors.left: waterfall.left

        ColorGradient {
            id: surfaceGradient
            ColorGradientStop { position: 0.0; color: "black" }
            ColorGradientStop { position: 0.2; color: "red" }
            ColorGradientStop { position: 0.5; color: "blue" }
            ColorGradientStop { position: 0.8; color: "yellow" }
            ColorGradientStop { position: 1.0; color: "black" }
        }

        ValueAxis3D {
            id: xAxis
            segmentCount: 8
            labelFormat: "%i"
            title: "Samples"
            titleVisible: true
            titleFixed: false
        }


        ValueAxis3D {
            id: yAxis
            segmentCount: 8
            labelFormat: "%i"
            title: "Value"
            titleVisible: true
            labelAutoRotation: 0
            titleFixed: false
        }

        ValueAxis3D {
            id: zAxis
            segmentCount: 5
            labelFormat: "%i m"
            title: "Distance"
            titleVisible: true
            titleFixed: false
        }

        Theme3D {
            id: customTheme
            type: Theme3D.ThemeQt
            lightStrength: 0.0
            ambientLightStrength: 1.0
            backgroundEnabled: false
            gridLineColor: "#AAAAAA"
            windowColor: "#EEEEEE"
        }

        TouchInputHandler3D {
            id: customInputHandler
            rotationEnabled: true
        }

        Surface3D {
            id: surfaceGraph
            width: surfaceView.width
            height: surfaceView.height

            shadowQuality: AbstractGraph3D.ShadowQualityNone
            selectionMode: AbstractGraph3D.SelectionSlice | AbstractGraph3D.SelectionItemAndColumn
            axisX: xAxis
            axisY: yAxis
            axisZ: zAxis

            theme: customTheme
            inputHandler: customInputHandler

            orthoProjection: false
            scene.activeCamera.cameraPreset: Camera3D.CameraPresetDirectlyAbove

            flipHorizontalGrid: true
            radialLabelOffset: 0.01

            horizontalAspectRatio: 1
            scene.activeCamera.zoomLevel: 85

            Surface3DSeries {
                id: surfaceSeries
                flatShadingEnabled: false
                drawMode: Surface3DSeries.DrawSurface
                baseGradient: surfaceGradient
                colorStyle: Theme3D.ColorStyleRangeGradient
                itemLabelFormat: "(@xLabel, @zLabel): @yLabel"

                ItemModelSurfaceDataProxy {
                    id: surfaceDataProxy
                    itemModel: dataModel
                    rowRole: "distance"
                    columnRole: "sample"
                    yPosRole: "value"
                }
            }
        }
    }

    RowLayout {
        id: buttonLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        opacity: 0.5


        PingButton {
            id: orthoToggle
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "Switch to perspective"
            onClicked: {
                if (surfaceGraph.orthoProjection === true) {
                    surfaceGraph.orthoProjection = false;
                    xAxis.labelAutoRotation = 30
                    yAxis.labelAutoRotation = 30
                    zAxis.labelAutoRotation = 30
                    customInputHandler.rotationEnabled = true
                    text = "Switch to orthographic"
                } else {
                    surfaceGraph.orthoProjection = true;
                    surfaceGraph.scene.activeCamera.cameraPreset = Camera3D.CameraPresetDirectlyAbove
                    surfaceSeries.drawMode &= ~Surface3DSeries.DrawWireframe;
                    xAxis.labelAutoRotation = 0
                    yAxis.labelAutoRotation = 0
                    zAxis.labelAutoRotation = 0
                    customInputHandler.rotationEnabled = false
                    text = "Switch to perspective"
                }
            }
        }

        PingButton {
            id: flipGridToggle
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "Toggle axis grid on top"
            onClicked: {
                onClicked: {
                    if (surfaceGraph.flipHorizontalGrid === true) {
                        surfaceGraph.flipHorizontalGrid = false;
                    } else {
                        surfaceGraph.flipHorizontalGrid = true;
                    }
                }
            }
        }

        PingButton {
            id: labelOffsetToggle
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "Toggle radial label position"
            visible: surfaceGraph.polar
            onClicked: {
                if (surfaceGraph.radialLabelOffset >= 1.0) {
                    surfaceGraph.radialLabelOffset = 0.01
                } else {
                    surfaceGraph.radialLabelOffset = 1.0
                }
            }
        }

        PingButton {
            id: surfaceGridToggle
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: "Toggle surface grid"
            visible: !surfaceGraph.orthoProjection
            onClicked: {
                if (surfaceSeries.drawMode & Surface3DSeries.DrawWireframe) {
                    surfaceSeries.drawMode &= ~Surface3DSeries.DrawWireframe;
                } else {
                    surfaceSeries.drawMode |= Surface3DSeries.DrawWireframe;
                }
            }
        }

    }

    Rectangle {
        id: legend
        anchors.margins: 20
        anchors.bottom: parent.bottom
        anchors.top: buttonLayout.bottom
        anchors.right: parent.right
        border.color: "black"
        border.width: 1
        width: 50
        rotation: 180
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.2; color: "red" }
            GradientStop { position: 0.5; color: "blue" }
            GradientStop { position: 0.8; color: "yellow" }
            GradientStop { position: 1.0; color: "white" }
        }
    }

    Text {
        anchors.verticalCenter: legend.bottom
        anchors.right: legend.left
        anchors.margins: 2
        text: surfaceGraph.axisY.min  + "%"
    }

    Text {
        anchors.verticalCenter: legend.verticalCenter
        anchors.right: legend.left
        anchors.margins: 2
        text: (surfaceGraph.axisY.max + surfaceGraph.axisY.min) / 2  + "%"
    }

    Text {
        anchors.verticalCenter: legend.top
        anchors.right: legend.left
        anchors.margins: 2
        text: surfaceGraph.axisY.max + "%"
    }

    ListModel {
        id: dataModel
        ListElement{ distance: "0"; sample: "0"; value: "0"; }
    }

    property var element: 0
    Timer {
        interval: 300; running: true; repeat: true
        onTriggered: {
            element += 1
            dataModel.clear()
            for (var j=0; j < 200; j++) {
                for (var i=0; i<200; i++) {
                    var data = {"distance": j.toString(), "sample": i.toString(), "value": Math.ceil(255*Math.random()).toString()}
                    dataModel.append(data)
                }
            }
        }
    }

}
