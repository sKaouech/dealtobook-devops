<#outputformat "plainText">
    <#assign requiredActionsText>
        <#if requiredActions??>
            <#list requiredActions>
                <#items as reqActionItem>${msg("requiredAction.${reqActionItem}")}<#sep>, </#sep>
                </#items>
            </#list>
        </#if>
    </#assign>
</#outputformat>

<html>
<body>
<#if requiredActions??>
<#list requiredActions>
<#items as reqActionItem>
<#if reqActionItem=='ACTIVATION_ACCOUNT'>
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
           <div> ${kcSanitize(msg("activationAccountBodyOHtml",link, linkExpiration, linkExpirationFormatter(linkExpiration,locale)))?no_esc}</div>
           <div> ${kcSanitize(msg("activationClientAccountBody1Html"))?no_esc}</div>
            <p><strong>${msg("emailBestRegards")}</strong></p>
            <img style="max-width: 100%;" src="https://i.imgur.com/aDExSeG.png"/>
            <p><strong>${msg("activationAccountTerms")}</strong></p>
        </div>
    </div>
<#elseif reqActionItem=='ACTIVATION_PROVIDER_ACCOUNT' >
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
                    <div> ${kcSanitize(msg("activationAccountBodyOHtml",link, linkExpiration, linkExpirationFormatter(linkExpiration,locale)))?no_esc}</div>
                    <div> ${kcSanitize(msg("activationProviderAccountBody1Html"))?no_esc}</div>
                    <p><strong>${msg("emailBestRegards")}</strong></p>
                    <img style="max-width: 100%;" src="https://i.imgur.com/aDExSeG.png"/>
                    <p><strong>${msg("activationAccountTerms")}</strong></p>
                </div>
            </div>
</body>
<#else>
    ${kcSanitize(msg("executeActionsBodyHtml",link, linkExpiration, realmName, requiredActionsText, linkExpirationFormatter(linkExpiration)))?no_esc}
</#if>
</#items>
</#list>
</#if>
</body>
</html>
