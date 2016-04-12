# Ti.AccountKit

Support for the Facebook AccountKit framework in Titanium Mobile to login using an email or phone number.

> The used framework is in preview version 1.0.0 and still has some crashes occurring. Feel free to submit PR's if a new framework version is released by Facebook.

<img src="http://abload.de/img/simulatorscreenshot1231k4v.png" width="650" />

## Usage

```xml
<ios>
    <plist>
        <dict>
            <key>FacebookAppID</key>
            <string>{your-fb-app-id}</string>
            <key>AccountKitClientToken</key>
            <string>{your-accountkit-client-token}</string>
        </dict>
    </plist>
</ios>
```

```javascript
var win = Ti.UI.createWindow({
    backgroundColor:'white'
});

var accountkit = require('ti.accountkit');
// One of RESPONSE_TYPE_AUTHORIZATION_CODE or RESPONSE_TYPE_ACCESS_TOKEN
accountkit.initialize(accountkit.RESPONSE_TYPE_AUTHORIZATION_CODE);

accountkit.addEventListener("success", function(e) {
    Ti.API.warn("success");
    Ti.API.warn(e);
});

accountkit.addEventListener("cancel", function(e) {
    Ti.API.warn("cancel");
    Ti.API.warn(e);
});

accountkit.addEventListener("error", function(e) {
    Ti.API.warn("error");
    Ti.API.warn(e);
});

var btn1 = Ti.UI.createButton({
    top: 40,
    title: "Login with Phone"
});

btn1.addEventListener("click", function() {
    accountkit.loginWithPhone();
});

var btn2 = Ti.UI.createButton({
    top: 80,
    title: "Login with E-Mail"
});

btn2.addEventListener("click", function() {
    accountkit.loginWithEmail();
});

win.add(btn1,btn2);
win.open();
```

