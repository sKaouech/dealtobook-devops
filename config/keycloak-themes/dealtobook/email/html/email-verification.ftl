<html>
<body>
<div style="padding: 30px;background: #e3e3e3;">
    <#if locale=='ar'>
    <div style="text-align: end;border-top: 5px solid #b3a605;padding: 30px;color: #212121;background: #fff;font-family: sans-serif,arial;">
        <#else>
        <div style="border-top: 5px solid #b3a605;padding: 30px;color: #212121;background: #fff;font-family: sans-serif,arial;">
            </#if>
            <span style="color: #00a5a5;font-weight: 600;">${msg("emailWelcomeDealToBook")}</span>
            <#if user.attributes.otherTitle??>
                <div style="font-size: 20px">${kcSanitize(msg("dearTitleHtml",user.attributes.otherTitle,user.lastName))?no_esc}</div>
            <#elseif user.attributes.title??>
                <div style="font-size: 20px">${kcSanitize(msg("dearTitleHtml",user.attributes.titleValue,user.lastName))?no_esc}</div>
            <#else>
                <div style="font-size: 20px">${kcSanitize(msg("dearTitleHtml",msg("defaulttitle"),user.lastName))?no_esc}</div>
            </#if>
            <div> ${kcSanitize(msg("emailVerificationBodyHtml",link, linkExpiration, linkExpirationFormatter(linkExpiration)))?no_esc}</div>
            <#--            <div> ${kcSanitize(msg("activationAccountBodyOHtml",link, linkExpiration, linkExpirationFormatter(linkExpiration,locale)))?no_esc}</div>-->
            <#--            <div> ${kcSanitize(msg("activationProviderAccountBody1Html"))?no_esc}</div>-->
            <p style="font-style: italic">
                <strong>${msg("emailBestRegards")}</strong><br/>
                <strong>${msg("customerServicesDepartment")}</strong>
            </p>
            <img style="max-width: 100%;" src="https://i.imgur.com/McTTDRX.png"/>
            <#--            <p><strong>${msg("activationAccountTerms")}</strong></p>-->
            <p style="margin-left: 50px;margin-right: 50px;">
                <em>${kcSanitize(msg("email.signature.text1","unsubscribe"))?no_esc}</em>
                <br/><br/>
                <em>${kcSanitize(msg("email.signature.text2"))}</em>
            </p>
            <br/><br/>
            <div style="margin-left: 50px;display: flex;flex-wrap: wrap;">
                <div style="flex: 0 0 33%;max-width: 33%;position: relative;width: 100%;">
                    <span style="display: block">${kcSanitize(msg("email.signature.text3"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text4"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text5"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text6"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text7"))}</span>
                </div>
                <div style="flex: 0 0 33%;max-width: 33%;position: relative;width: 100%;"></div>
                <div style="flex: 0 0 33%;max-width: 33%;position: relative;width: 100%;">
                    <span style="display: block">${kcSanitize(msg("email.signature.text31"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text41"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text51"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text61"))}</span>
                    <span style="display: block">${kcSanitize(msg("email.signature.text71"))}</span>
                </div>
            </div>
            <br></br>
            <span style="font-size: 7px">${kcSanitize(msg("email.signature.end"))}</span>
        </div>
    </div>
</div>
</body>
</html>
