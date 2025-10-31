window.onload = function () {

    console.log('login.js - onload()');

    // Initialise all MDC text fields
    document.querySelectorAll('.mdc-text-field').forEach(function (e) {
        new mdc.textField.MDCTextField(e);
    });

    // Initialise all MDC text field icons
    document.querySelectorAll('.mdc-text-field__icon').forEach(function (e) {
        new mdc.textField.MDCTextFieldIcon(e);
    });

    // Add a ripple effect to all MDC buttons
    document.querySelectorAll('.mdc-button').forEach(function (e) {
        mdc.ripple.MDCRipple.attachTo(e);
    });


    function httpGetAsync(theUrl, callback) {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function () {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                callback(xmlHttp.responseText);
        }
        xmlHttp.open("GET", theUrl, true); // true for asynchronous
        xmlHttp.send(null);
    }

    // httpGetAsync("http://localhost:8804/api/countries/uri", function (value) {
    //     console.log('value', value);
    //
    // })
    // onGet();
    onTierCat();

    function onGet() {
        var url = "http://localhost:8801/api/countries/uri";
        var headers = {}

        fetch(url, {
            method: "GET",
            mode: 'cors',
            headers: headers
        })
            .then(function (response) {
                return response.json();
            })
            .then(function (data) {
                console.log('data', data);
            })
            .catch(function (error) {
                // document.getElementById('messages').value = error;
            });
    }

    function changeLangue() {
        var e = document.getElementById("div2"); //Get the element
        e.setAttribute("dir", "rtl"); //Change id to div3

    }
    function onTierCat() {
        document.getElementById('tierCategory').value = 'PROVIDER'

    }
    function showPsw(){

    }
};
