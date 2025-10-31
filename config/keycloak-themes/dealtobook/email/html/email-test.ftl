<html>
<body>
<#--${testNewVariable}-->
${kcSanitize(msg("emailTestBodyHtml",realmName))?no_esc}
</body>
</html>
