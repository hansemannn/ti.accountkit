# Ti.AccountKit

Support for the Facebook AccountKit framework in Titanium Mobile to login using an email or phone number.

> Note: This is the iOS version of Ti.AccountKit. You might want to check [appwert/ti.accountkit](https://github.com/AppWerft/Ti.AccountKit) for the Android equivalent 🚀.

<img src="http://abload.de/img/screens1yk59.jpg" width="1000" />

## Usage

Configure your tiapp.xml properly:

```xml
<ios>
    <plist>
        <dict>
            <key>CFBundleURLTypes</key>
            <array>
                <dict>
                    <key>CFBundleURLSchemes</key>
                    <array>
                        <string>ak{your-fb-app-id}</string>
                    </array>
                </dict>
            </array>
            <key>FacebookAppID</key>
            <string>{your-fb-app-id}</string>
            <key>AccountKitClientToken</key>
            <string>{your-accountkit-client-token}</string>
        </dict>
    </plist>
</ios>
```

Check this example code on using both phone- and email-login: 

```javascript
var win = Ti.UI.createWindow({
    backgroundColor:'white'
});

var accountkit = require('ti.accountkit');
// One of RESPONSE_TYPE_AUTHORIZATION_CODE or RESPONSE_TYPE_ACCESS_TOKEN
accountkit.initialize(accountkit.RESPONSE_TYPE_AUTHORIZATION_CODE);

accountkit.addEventListener("login", function(e) {
    Ti.API.warn("success: " + e.success);
    Ti.API.warn(e);
});

var btn1 = Ti.UI.createButton({
    top: 40,
    title: "Login with Phone"
});

btn1.addEventListener("click", function() {
    accountkit.loginWithPhone();

    // Optional: You can also pass a phone number and country-code to pre-fill the form
    // accountkit.loginWithPhone('<phone-number>', 'DE');
});

var btn2 = Ti.UI.createButton({
    top: 80,
    title: 'Login with E-Mail'
});

btn2.addEventListener('click', function() {
    accountkit.loginWithEmail();

    // Optional: You can also pass an email-address to pre-fill the form
    // accountkit.loginWithEmail('john@doe.com');

    // Use accountkit.logout() to logout and pass an optional callback to
    // handle the asynchronous logout.
});

win.add(btn1,btn2);
win.open();
```

