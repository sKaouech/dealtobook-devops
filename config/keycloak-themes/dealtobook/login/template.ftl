<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false showAnotherWayIfPresent=true>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" class="${properties.kcHtmlClass!}" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="robots" content="noindex, nofollow">

        <#if properties.meta?has_content>
            <#list properties.meta?split(' ') as meta>
                <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
            </#list>
        </#if>
        <title>${msg("loginTitle",(realm.displayName!''))}</title>
        <link rel="icon" href="${url.resourcesPath}/img/moorishHome.png"/>
        <#if properties.stylesCommon?has_content>
            <#list properties.stylesCommon?split(' ') as style>
                <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet"/>
            </#list>
        </#if>
        <#if properties.styles?has_content>
            <#list properties.styles?split(' ') as style>
                <link href="${url.resourcesPath}/${style}" rel="stylesheet"/>
            </#list>
        </#if>
        <#if properties.scripts?has_content>
            <#list properties.scripts?split(' ') as script>
                <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
            </#list>
        </#if>
        <#if scripts??>
            <#list scripts as script>
                <script src="${script}" type="text/javascript"></script>
            </#list>
        </#if>
    </head>

    <body class="${properties.kcBodyClass!}">


    <div class="${properties.kcLoginClass!}" style="padding-top: 0px;">
        <header class="header-deal">
            <nav class="navbar" role="navigation" style="display: inherit;padding: 0;">
                <div class="container-deal" style="display: flex">
                    <a class="navbar-brand logo" href="https://www.dealtobook.com" style="flex: 1; align-self: center">
                        <img src="${url.resourcesPath}/img/logo.gif" alt="logo" class="nav-logo"/>
                    </a>
                    <!-- Brand and toggle get grouped for better mobile display -->
                    <div class="menu-container js_nav-item"></div>
                    <!-- HAMBURGUER MENU ICON -->
                    <input type="checkbox" name="toggle" id="toggle"/>
                    <label for="navbar-toggle"></label>
                    <!-- Collect the nav links, forms, and other content for toggling -->
                    <div class="menu-mobile">
                        <div class="collapse navbar-collapse">
                            <div class="menu-container">
                                <ul class="nav navbar-nav-deal container-deal-right">
                                    <li class="js_nav-item nav-item">
                                        <a class="nav-item-child active">Home</a>
                                    </li>
                                    <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
                                        <li class="${properties.kcLocaleMainClass!} js_nav-item nav-item" id="kc-locale">
                                            <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                                                <div id="kc-locale-dropdown" class="${properties.kcLocaleDropDownClass!}">
                                                    <a class="nav-item-child-local" href="#" id="kc-current-locale-link">${locale.current}</a>
                                                    <ul class="${properties.kcLocaleListClass!}">
                                                        <#list locale.supported as l>
                                                            <li class="${properties.kcLocaleListItemClass!}">
                                                                <a class="${properties.kcLocaleItemClass!}" href="${l.url}" onclick="display();changeLangue(${l.label})">
                                                                    <img alt="flag" style="width: 25px;margin-right: 5px;" src="${url.resourcesPath}/img/flags/${l.label}.png"/>
                                                                    ${l.label}</a>
                                                            </li>
                                                        </#list>
                                                    </ul>
                                                </div>
                                            </div>
                                        </li>
                                    </#if>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </nav>
        </header>

        <div class="${properties.kcFormCardClass!}">
            <header class="${properties.kcFormHeaderClass!}">
                <#--<div class="img-logo"></div>-->
                <#--                <#if realm.internationalizationEnabled  && locale.supported?size gt 1>-->
                <#--                    <div class="${properties.kcLocaleMainClass!}" id="kc-locale">-->
                <#--                        <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">-->
                <#--                            <div id="kc-locale-dropdown" class="${properties.kcLocaleDropDownClass!}">-->
                <#--                                <a href="#" id="kc-current-locale-link">${locale.current}</a>-->
                <#--                                <ul class="${properties.kcLocaleListClass!}">-->
                <#--                                    <#list locale.supported as l>-->
                <#--                                        <li class="${properties.kcLocaleListItemClass!}">-->
                <#--                                            <a class="${properties.kcLocaleItemClass!}" href="${l.url}" onclick="display();changeLangue(${l.label})">${l.label}</a>-->
                <#--                                        </li>-->
                <#--                                    </#list>-->
                <#--                                </ul>-->
                <#--                            </div>-->
                <#--                        </div>-->
                <#--                    </div>-->
                <#--                </#if>-->

                <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
                    <#if displayRequiredFields>
                        <div class="${properties.kcContentWrapperClass!}">
                            <div class="${properties.kcLabelWrapperClass!} subtitle">
                                <span class="subtitle"><span class="required">*</span> ${msg("requiredFields")}</span>
                            </div>
                            <div class="col-md-10">
                                <h1 id="kc-page-title"><#nested "header"></h1>
                            </div>
                        </div>
                    <#else>
                        <h1 id="kc-page-title"><#nested "header"></h1>
                    </#if>
                <#else>
                    <#if displayRequiredFields>
                        <div class="${properties.kcContentWrapperClass!}">
                            <div class="${properties.kcLabelWrapperClass!} subtitle">
                                <span class="subtitle"><span class="required">*</span> ${msg("requiredFields")}</span>
                            </div>
                            <div class="col-md-10">
                                <#nested "show-username">
                                <div id="kc-username" class="${properties.kcFormGroupClass!}">
                                    <label id="kc-attempted-username">${auth.attemptedUsername}</label>
                                    <a id="reset-login" href="${url.loginRestartFlowUrl}">
                                        <div class="kc-login-tooltip">
                                            <i class="${properties.kcResetFlowIcon!}"></i>
                                            <span class="kc-tooltip-text">${msg("restartLoginTooltip")}</span>
                                        </div>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <#else>
                        <#nested "show-username">
                        <div id="kc-username" class="²${properties.kcFormGroupClass!}">
                            <label id="kc-attempted-username">${auth.attemptedUsername}</label>
                            <a id="reset-login" href="${url.loginRestartFlowUrl}">
                                <div class="kc-login-tooltip">
                                    <i class="${properties.kcResetFlowIcon!}"></i>
                                    <span class="kc-tooltip-text">${msg("restartLoginTooltip")}</span>
                                </div>
                            </a>
                        </div>
                    </#if>
                </#if>
            </header>
            <div id="kc-content">
                <div id="kc-content-wrapper">

                    <#-- App-initiated actions should not see warning messages about the need to complete the action -->
                    <#-- during login.                                                                               -->
                    <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                        <div class="alert-${message.type} ${properties.kcAlertClass!} pf-m-<#if message.type = 'error'>danger<#else>${message.type}</#if>">
                            <div class="pf-c-alert__icon">
                                <#if message.type = 'success'><span class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                                <#if message.type = 'warning'><span class="${properties.kcFeedbackWarningIcon!}"></span></#if>
                                <#if message.type = 'error'><span class="${properties.kcFeedbackErrorIcon!}"></span></#if>
                                <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
                            </div>
                            <span class="${properties.kcAlertTitleClass!}">${kcSanitize(message.summary)?no_esc}</span>
                        </div>
                    </#if>

                    <#nested "form">

                    <#if auth?has_content && auth.showTryAnotherWayLink() && showAnotherWayIfPresent>
                        <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post">
                            <div class="${properties.kcFormGroupClass!}">
                                <input type="hidden" name="tryAnotherWay" value="on"/>
                                <a href="#" id="try-another-way"
                                   onclick="document.forms['kc-select-try-another-way-form'].submit();return false;">${msg("doTryAnotherWay")}</a>
                            </div>
                        </form>
                    </#if>

                    <#if displayInfo>
                        <div id="kc-info" class="${properties.kcSignUpClass!}">
                            <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                                <#nested "info">
                            </div>
                        </div>
                    </#if>
                </div>
            </div>

        </div>
    </div>
    </body>
    <script>
        // tabs

    </script>

    </html>
</#macro>
