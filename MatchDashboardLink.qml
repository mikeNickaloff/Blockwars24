import QtQuick

QtObject {
    id: link

    property var topDashboard
    property var bottomDashboard
    property bool handshakeStarted: false

    function bindDashboards(top, bottom) {
        try {
            if (topDashboard && topDashboard.messageDispatched)
                topDashboard.messageDispatched.disconnect(link._routeFromTop)
        } catch (error) {
        }
        try {
            if (bottomDashboard && bottomDashboard.messageDispatched)
                bottomDashboard.messageDispatched.disconnect(link._routeFromBottom)
        } catch (error) {
        }

        topDashboard = top
        bottomDashboard = bottom
        handshakeStarted = false

        if (topDashboard && topDashboard.messageDispatched)
            topDashboard.messageDispatched.connect(link._routeFromTop)
        if (bottomDashboard && bottomDashboard.messageDispatched)
            bottomDashboard.messageDispatched.connect(link._routeFromBottom)
    }

    function startHandshake() {
        if (!topDashboard || !bottomDashboard || handshakeStarted)
            return
        handshakeStarted = true
        topDashboard.beginHandshake()
    }

    function _routeFromTop(message) {
        if (bottomDashboard && bottomDashboard.receiveMessage)
            bottomDashboard.receiveMessage(message)
    }

    function _routeFromBottom(message) {
        if (topDashboard && topDashboard.receiveMessage)
            topDashboard.receiveMessage(message)
    }
}
