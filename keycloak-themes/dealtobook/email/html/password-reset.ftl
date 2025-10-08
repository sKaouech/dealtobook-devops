<html>
    <head>
        <title>${msg("passwordResetSubject")}</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    </head>
    <body>
        <div style="padding: 30px;background: #e3e3e3;">
            <#if locale=='ar'>
            <div style="text-align: end;border-top: 5px solid #b3a605;padding: 30px;color: #212121;background: #fff;font-family: sans-serif,arial;">
                <#else>
                <div style="border-top: 5px solid #b3a605;padding: 30px;color: #212121;background: #fff;font-family: sans-serif,arial;">
                    </#if>
                    <span style="color: #00a5a5;font-weight: 600;">${msg("emailWelcomeDealToBook")}</span>
                    <#if user.attributes.title??>
                        <div style="font-size: 20px">${kcSanitize(msg("dearTitleHtml",user.attributes.title,user.firstName))?no_esc}</div>
                    <#else>
                        <div style="font-size: 20px">${kcSanitize(msg("dearTitleHtml",msg("title"),user.firstName))?no_esc}</div>
                    </#if>
                    <div>${kcSanitize(msg("passwordResetBody1HtmlDeal"))?no_esc}</div>
                    <div>
                        ${kcSanitize(msg("passwordResetBody3HtmlDeal",link, linkExpiration, linkExpirationFormatter(linkExpiration)))?no_esc}
                    </div>
                    <div>${kcSanitize(msg("passwordResetBody2HtmlDeal"))?no_esc}</div>
                    <p>
                        <strong><span>${msg("emailBestRegards")}</span></strong>
                    </p>
                    <img style="max-width: 100%;" src="https://i.imgur.com/aDExSeG.png"/>
                </div>
            </div>
        </div>
    </body>
</html>
