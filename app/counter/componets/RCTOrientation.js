/*************************************************************************
 * Description: 方向组件
 * Author: raojia
 * Mail: raojia@le.com
 * Created Time: 2016-12-11
 * Modified Time: 2016-12-11
 ************************************************************************/
'use strict';

import { NativeModules, NativeEventEmitter } from 'react-native';

const Orientation = NativeModules.OrientationModule;
const myNativeEvt = new NativeEventEmitter(Orientation);  //创建自定义事件接口

var listeners = {};
// const onOrientationDidChangeEvent = "onOrientationDidChange";

var id = 0;
var META = '__orient_listener_id';

function getKey(listener) {
    if (!listener.hasOwnProperty(META)) {
        if (!Object.isExtensible(listener)) {
            return 'F';
        }
        Object.defineProperty(listener, META, {
            value: 'L' + ++id,
        });
    }
    return listener[META];
};

module.exports = {

    ORIENTATION_LANDSCAPE: Orientation.ORIENTATION_LANDSCAPE,
    ORIENTATION_PORTRAIT: Orientation.ORIENTATION_PORTRAIT,
    ORIENTATION_REVERSE_LANDSCAPE: Orientation.ORIENTATION_REVERSE_LANDSCAPE,
    ORIENTATION_REVERSE_PORTRAIT: Orientation.ORIENTATION_REVERSE_PORTRAIT,
    ORIENTATION_UNSPECIFIED:Orientation.ORIENTATION_UNSPECIFIED,

    getOrientation(cb) {
        Orientation.getOrientation((error, orientation) => {
            cb(error, orientation);
        });
    },
    setOrientation(orientation) {
        Orientation.setOrientation(orientation);
    },
    addOnOrientationListener(cb) {
        var key = getKey(cb);
        listeners[key] = myNativeEvt.addListener(Orientation.EVENT_ORIENTATION_CHANG,
            (body) => {
                cb(body.orientation);
            });
    },
    removeOnOrientationListener(cb) {
        var key = getKey(cb);
        if (!listeners[key]) {
            return;
        }
        listeners[key].remove();
        listeners[key] = null;
    },
    getInitialOrientation() {
        return Orientation.initialOrientation;
    }
};
