import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

Window {
    id: root

    width: 800
    height: 600
    visible: true
    title: qsTr("Ellipse Arc")

    readonly property real cx: ( rect_tl.x + rect_br.x ) * 0.5
    readonly property real cy: ( rect_tl.y + rect_br.y ) * 0.5
    readonly property real rx: Math.abs( rect_tl.x - rect_br.x ) * 0.5
    readonly property real ry: Math.abs( rect_tl.y - rect_br.y ) * 0.5
    readonly property bool antiClockwise: true
    readonly property real scaleFactor: ry / rx

    onScaleFactorChanged: {
        rect_start.updatePositionFromAngle( rect_start.currentAngle )
        rect_end.updatePositionFromAngle( rect_end.currentAngle )
    }

    Rectangle {
        id: rect_tl

        width: 8
        height: 8
        radius: 4
        color: "orange"
        transform: Translate {
            x: -4
            y: -4
        }

        MouseArea {
            anchors.fill: parent
            drag {
                target: parent
                threshold: 0
            }
        }

        Component.onCompleted: {
            x = root.width * 0.5 - 200
            y = root.height * 0.5 - 200
        }
    }

    Rectangle {
        id: rect_br


        width: 8
        height: 8
        radius: 4
        color: "royalblue"
        transform: Translate {
            x: -4
            y: -4
        }

        MouseArea {
            anchors.fill: parent
            drag {
                target: parent
                threshold: 0
            }
        }

        Component.onCompleted: {
            x = root.width * 0.5 + 200
            y = root.height * 0.5 + 200
        }
    }

    Rectangle {
        id: rect_c

        x: cx
        y: cy
        width: 8
        height: 8
        radius: 4
        border {
            color: "palegreen"
            width: 1
        }
        transform: Translate {
            x: -4
            y: -4
        }
    }

    Rectangle {
        id: rect_start

        property real currentAngle: 0

        visible: bgrp_shapes.checkedButton.shape
        width: 8
        height: 8
        radius: 4
        color: "seagreen"
        transform: Translate {
            x: -4
            y: -4
        }

        MouseArea {
            id: ma_start

            anchors.fill: parent
            onPositionChanged: {
                let mapped = mapToItem( rect_c, mouseX, mouseY )
                let angle = calculateAngle( 0, 0, mapped.x, mapped.y )
                if( pressed ) parent.updatePositionFromAngle( angle )
            }
        }

        Component.onCompleted: calculateRadialPosition( this, cx, cy, rx, ry, 0 )

        function updatePositionFromAngle( angle ) {
            currentAngle = angle
            calculateRadialPosition( this, cx, cy, rx, ry, angle )
            updateArcFlags()
            cnvs_arc.requestPaint()
        }
    }

    Rectangle {
        id: rect_end

        property real currentAngle: Math.PI

        visible: bgrp_shapes.checkedButton.shape
        width: 8
        height: 8
        radius: 4
        color: "orangered"
        transform: Translate {
            x: -4
            y: -4
        }

        MouseArea {
            id: ma_end

            anchors.fill: parent
            onPositionChanged: {
                let mapped = mapToItem( rect_c, mouseX, mouseY )
                let angle = calculateAngle( 0, 0, mapped.x, mapped.y )
                if( pressed ) parent.updatePositionFromAngle( angle )
            }
        }

        Component.onCompleted: calculateRadialPosition( this, cx, cy, rx, ry, 0 )

        function updatePositionFromAngle( angle ) {
            currentAngle = angle
            calculateRadialPosition( this, cx, cy, rx, ry, angle )
            updateArcFlags()
            cnvs_arc.requestPaint()
        }
    }

    Row {
        id: row_shapes

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 4
        }
        spacing: 16

        RoundButton {
            id: rb_ellipse

            readonly property int shape: 0

            width: 64
            height: 64
            checked: true
            checkable: true
            text: "Ellipse"
        }

        RoundButton {
            id: rb_arc

            readonly property int shape: 1

            width: 64
            height: 64
            checkable: true
            text: "Arc"
        }
    }

    ButtonGroup {
        id: bgrp_shapes

        buttons: row_shapes.children
        onCheckedButtonChanged: cnvs_arc.requestPaint()
    }

    Canvas {
        id: cnvs_arc

        anchors.fill: parent
        onPaint: {
            let ctx = getContext( "2d" )
            ctx.clearRect( 0, 0, width, height )

            ctx.lineWidth = 1.0

            /******************************************************

              Draw a rectangle between control points

            ******************************************************/

            ctx.save()
            ctx.strokeStyle = "royalblue"
            ctx.translate( -rx, -ry )
            ctx.beginPath()
            ctx.strokeRect( cx, cy, rx * 2.0, ry * 2.0 )
            ctx.closePath()
            ctx.restore()

            ctx.moveTo( cx, cy )
            ctx.lineTo( rect_tl.x, rect_tl.y )
            ctx.moveTo( cx, cy )
            ctx.lineTo( rect_br.x, rect_tl.y )
            ctx.moveTo( cx, cy )
            ctx.lineTo( rect_br.x, rect_br.y )
            ctx.moveTo( cx, cy )
            ctx.lineTo( rect_tl.x, rect_br.y )
            ctx.stroke()

            ctx.save()
            ctx.strokeStyle = "crimson"

            ctx.beginPath()
            ctx.strokeStyle = "#cc7226"
            ctx.lineWidth = 1.0

            let rotate = sb_rotate.value
            let large_arc_flag = cb_largeArc.checked ? 1 : 0
            let sweep_flag = cb_sweep.checked ? 1 : 0
            let pathString =
                "M " + rect_start.x + " " + rect_start.y +
                " A " + rx + " " + ry + " " + rotate + " " + large_arc_flag + " " + sweep_flag + " " + rect_end.x + " " + rect_end.y

            if( bgrp_shapes.checkedButton.shape )
                ctx.path = pathString
            else {
                let tlx = rect_tl.x < rect_br.x ? rect_tl.x : rect_br.x
                let tly = rect_tl.y < rect_br.y ? rect_tl.y : rect_br.y
                ctx.ellipse( tlx, tly, rx * 2, ry * 2 )
            }

            ctx.stroke()
            ctx.restore()

        }
    }

    Row {
        visible: false
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "start"
        }

        TextField {
            enabled: false
            width: 128
            text: convertToDegrees( rect_start.currentAngle ).toFixed( 2 ).toString()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "end"
        }

        TextField {
            enabled: false
            width: 128
            text: convertToDegrees( rect_end.currentAngle ).toFixed( 2 ).toString()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "ellipse"
        }

        CheckBox {
            id: cb_ellipse

            onCheckStateChanged: cnvs_arc.requestPaint()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "large arc"
        }

        CheckBox {
            id: cb_largeArc

            onCheckStateChanged: cnvs_arc.requestPaint()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "sweep"
        }

        CheckBox {
            id: cb_sweep

            onCheckStateChanged: cnvs_arc.requestPaint()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "rotate"
        }

        SpinBox {
            id: sb_rotate
            width: 128
            from: 0
            to: 360
            value: 0

            onValueChanged: cnvs_arc.requestPaint()
        }
    }

    function convertToDegrees( angle ) {
        return angle / Math.PI * 180.0
    }

    function calculateAngle( x1, y1, x2, y2 ) {
        let dirX = x2 - x1
        let dirY = y1 - y2

        let radius = Math.max( rx, ry )
        let a = rx / radius
        let b = ry / radius

        return Math.atan2( dirY, dirX )
    }

    function calculateRadialPosition( item, cx, cy, rx, ry, angle ) {
        item.x = calculateRadialX( cx, rx, angle )
        item.y = calculateRadialY( cy, ry, angle )
    }

    function calculateRadialX( cx, rx, angle ) {
        let a = rx
        let b = ry
        let a2 = Math.pow( a , 2 )
        let b2 = Math.pow( b, 2 )
        let tan2 = Math.pow( Math.tan( angle ), 2 )
        let PI_HALF = Math.PI * 0.5

        let result = ( a * b ) / ( Math.sqrt( b2 + a2 * tan2 ) )

        return -PI_HALF < angle && angle < PI_HALF ? cx + result : cx - result
    }

    function calculateRadialY( cy, ry, angle ) {
        let a = rx
        let b = ry
        let a2 = Math.pow( a , 2 )
        let b2 = Math.pow( b, 2 )
        let tan2 = Math.pow( Math.tan( angle ), 2 )
        let PI_HALF = Math.PI * 0.5

        let result = ( a * b ) / ( Math.sqrt( a2 + b2 / tan2 ) )

        return angle < 0 ? cy + result : cy - result
    }

    function angle( v0, v1, v2 ) {
        return (( Math.atan2( v2.y - v1.y, v2.x - v1.x ) - Math.atan2( v0.y - v1.y, v0.x - v1.x ) + 3 * Math.PI ) % ( 2 * Math.PI ) - Math.PI )
    }

    function find_angle(A,B,C) {
        var AB = Math.sqrt(Math.pow(B.x-A.x,2)+ Math.pow(B.y-A.y,2));
        var BC = Math.sqrt(Math.pow(B.x-C.x,2)+ Math.pow(B.y-C.y,2));
        var AC = Math.sqrt(Math.pow(C.x-A.x,2)+ Math.pow(C.y-A.y,2));

        return Math.acos((BC*BC+AB*AB-AC*AC) / (2*BC*AB)) * (180 / Math.PI);
    }

    function updateArcFlags() {
        let start = { x: rect_start.x, y: rect_start.y }
        let center = { x: rect_c.x, y: rect_c.y }
        let end = { x: rect_end.x, y: rect_end.y }

        let cs = { x: start.x  -  center.x, y: ( start.y -   center.y)  }
        let ce = { x: end.x    -  center.x, y: ( end.y   -   center.y)  }

        let sc = { x: center.x -  start.x,  y: ( center.y  -   start.y) }
        let se = { x: end.x    -  start.x,  y: ( end.y     -   start.y) }

        let sce = angle( start, center, end  )
        let esc = angle( end, start, center )

        console.log( "sce: " + convertToDegrees( sce ) )
        console.log( "esc: " + convertToDegrees( esc ) )
        console.log( "--------" )

        cb_largeArc.checked = sce < 0 ? false : true
    }

    function angleBetween( v0, v1 ) {
        let dp = dotProduct( v0, v1 )
        let mag0 = magnitude( v0 )
        let mag1 = magnitude( v1 )

        return Math.acos( dp / mag0 / mag1 )
    }

    function dotProduct( v0, v1 ) {
        return v0.x * v1.x + v0.y * v1.y
    }

    function magnitude( v ) {
        return Math.sqrt( v.x * v.x + v.y * v.y )
    }

    function normalize( v ) {
        let mag = magnitude( v )
        return {
            x: v.x / mag,
            y: v.y / mag
        }
    }
}
