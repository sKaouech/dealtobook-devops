<html>
<body>
${kcSanitize(msg("eventUpdatePasswordBodyHtml",event.date, event.ipAddress))?no_esc}

</body>
</html>
<#-- email-update-password.ftl -->
<html>
<body>
<p>Dear ${user.username},</p>

<p>To secure your account, please click the link below to set a new password:</p>

<p><a href="${link}">Set New Password</a></p>

<p>This link will expire within 12 hours.</p>

<p>If you did not request this action, please ignore this email.</p>

<p>Thank you,<br/>The Dealtobook Team</p>
</body>
</html>
