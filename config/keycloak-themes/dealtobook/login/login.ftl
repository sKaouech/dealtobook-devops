<#import "template.ftl" as layout>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        <div class="label2"></div>
        <div class="label">${msg("signin")}</div>
<#--    <img src="${url.resourcesPath}/img/moorishHome.png" alt="" class="login-img-logo"/>-->
    <#elseif section = "form">
    <div id="kc-form">
        <div id="kc-form-wrapper">
        <#if realm.password>
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <label for="username" class="${properties.kcLabelClass!}">
                        <#if !realm.loginWithEmailAllowed>${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                        <#else>${msg("email")}
                        </#if>
                    </label>
                    <#if usernameEditDisabled??>
                        <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" disabled/>
                    <#else>
                        <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" autofocus
                               autocomplete="off"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                        />
                        <#if messagesPerField.existsError('username','password')>
                            <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </span>
                        </#if>
                    </#if>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>

                    <input tabindex="2" id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="off"
                           aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                    />
                </div>

                <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                    <div id="kc-form-options">
                        <#if realm.rememberMe && !usernameEditDisabled??>
                            <div style="display:flex;" class="checkbox">
                                <label>
                                    <#if login.rememberMe??>
                                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked>
                                    <#else>
                                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox">
                                    </#if>
                                </label>
                                <span>${msg("rememberMe")}</span>
                            </div>
                        </#if>
                    </div>
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                            <#if realm.resetPasswordAllowed>
                                <span><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                            </#if>
                    </div>

                </div>

                <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                           name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>
                </div>
            </form>
        </#if>
        </div>

        <#if realm.password && social.providers??>
            <div id="kc-social-providers" class="${properties.kcFormSocialAccountSectionClass!}">
                <div style="display: flex;margin-top: 8px">
                    <hr width="45%" color="blue">
                    <span style="margin:0 10px 0 10px">OR</span>
                    <hr width="45%" color="blue">
                </div>
                <ul class="${properties.kcFormSocialAccountListClass!} <#if social.providers?size gt 3>${properties.kcFormSocialAccountListGridClass!}</#if>">
                    <#list social.providers as p>
                        <a id="social-${p.alias}"
                           class="${properties.kcFormSocialAccountListButtonClass!} <#if social.providers?size gt 3>${properties.kcFormSocialAccountGridItem!}</#if>"
                           type="button" href="${p.loginUrl}">
                            <#if p.iconClasses?has_content>
                                <i class="${properties.kcCommonLogoIdP!} ${p.iconClasses!}" aria-hidden="true"></i>
                                <span class="${properties.kcFormSocialAccountNameClass!} kc-social-icon-text">${p.displayName!}</span>
                            <#else>
                                <span class="${properties.kcFormSocialAccountNameClass!}">${p.displayName!}</span>
                            </#if>
                        </a>
                    </#list>
                </ul>
            </div>
        </#if>

    </div>
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">

                <div id="kc-registration">
<#--                    <span>${msg("noAccount")} </span>-->
                    <span style="margin-left: 100px;
                margin-top: 5px;
                            margin-right: 100px;
                            padding: 10px 15px;
                            border-radius: 50px;
                            background-color: rgba(4, 32, 43, 0.32);
                            color: white;"   href="${url.registrationUrl}"> ${msg("doRegister")}</span>

                    <div style="display: flex;">
                        <a class="pf-c-button pf-m-control pf-m-block register-button" type="button" href="https://administration-dev.dealtobook.com/register/client">
                            <i class="client-register-icon"></i>
                            <span class="register-button-title ">${msg("doRegisterClient")}</span>
                        </a>
                        <a class="pf-c-button pf-m-control pf-m-block register-button" type="button" href="https://administration-dev.dealtobook.com/register/provider">
                            <i class="provider-register-icon"></i>
                            <span class="register-button-title ">${msg("doRegisterProvider")}</span>
                        </a>
                        <a class="pf-c-button pf-m-control pf-m-block register-button" type="button" href="https://administration-dev.dealtobook.com/register/agency">
                            <i class="agency-register-icon"></i>
                            <span class="register-button-title ">${msg("doRegisterAgency")}</span>
                        </a>
                    </div>
                </div>

            </div>
        </#if>

    </#if>

</@layout.registrationLayout>
