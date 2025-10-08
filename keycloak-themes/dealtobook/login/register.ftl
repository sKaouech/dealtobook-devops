<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm'); section>
    <#if section = "header">
        <div class="label2"></div>
        <div class="label">${msg("signout")}</div>
    <#--<img src="resources/img/moorishHome.png">-->
    <#--${msg("registerTitle")}-->
    <#elseif section = "form">
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
            <input class="input-tab" id="tab1" type="radio" name="tabs" checked>
            <label class="label-tab" for="tab1">Client</label>
            <input class="input-tab" id="tab2" type="radio" name="tabs">
            <label class="label-tab" for="tab2">Provider</label>
            <input class="input-tab" id="tab3" type="radio" name="tabs">
            <label class="label-tab" for="tab3">Agency</label>
            <section id="content1">
                <div class="  ${properties.kcInputRegisterWrapperClass!}">
                    <div>
                        <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
                    </div>
                    <div>
                        <select id="user.attributes.title" class="mdc-select__native-control" name="user.attributes.title"
                                value="${(register.formData['user.attributes.title']!'')}">
                            <option value="" disabled></option>
                            <option value="${msg("register.title.MR")}">${msg("register.title.MR")}</option>
                            <option value="${msg("register.title.MRS")}">${msg("register.title.MRS")}</option>
                            <option value="${msg("register.title.MS")}">${msg("register.title.MS")}</option>
                            <option value="${msg("register.title.MISS")}">${msg("register.title.MISS")}</option>
                        </select>
                    </div>
                </div>
                <div class="  ${properties.kcInputRegisterWrapperClass!}">
                    <div>
                        <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
                    </div>
                    <div>
                        <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName"
                               value="${(register.formData.firstName!'')}"
                               aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>"
                        />

                        <#if messagesPerField.existsError('firstName')>
                            <span id="input-error-firstname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('firstName'))?no_esc}
                        </span>
                        </#if>
                    </div>
                </div>

                <div class="  ${properties.kcInputRegisterWrapperClass!}">
                    <div>
                        <label for="lastName" class="${properties.kcLabelClass!}">${msg("lastName")}</label>
                    </div>
                    <div>
                        <input type="text" id="lastName" class="${properties.kcInputClass!}" name="lastName"
                               value="${(register.formData.lastName!'')}"
                               aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"
                        />

                        <#if messagesPerField.existsError('lastName')>
                            <span id="input-error-lastname" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('lastName'))?no_esc}
                        </span>
                        </#if>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!} ${properties.kcInputRegisterWrapperClass!}">
                    <div>
                        <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                    </div>
                    <div>
                        <input type="text" id="email" class="${properties.kcInputClass!}" name="email"
                               value="${(register.formData.email!'')}" autocomplete="email"
                               aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"
                        />

                        <#if messagesPerField.existsError('email')>
                            <span id="input-error-email" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('email'))?no_esc}
                        </span>
                        </#if>
                    </div>
                </div>
                <div class="${properties.kcInputRegisterWrapperClass!} ${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('phone',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="user.attributes.phone" class="${properties.kcLabelClass!}">${msg("phone")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!}">
                        <input type="text" id="user.attributes.phone"
                               class="${properties.kcInputClass!}" name="user.attributes.phone"
                               value="${(register.formData['user.attributes.phone']!'')}"/>
                    </div>
                </div>
                <input type="text" id="user.attributes.tierCategory"
                       style="display:none;"
                       class="${properties.kcInputClass!}" name="user.attributes.tierCategory"
                       value="${(register.formData['user.attributes.tierCategory']!'')}"/>
                <div class="  ${properties.kcInputRegisterWrapperClass!}">
                    <div>
                        <label for="user.attributes.country" class="${properties.kcLabelClass!}">${msg("country")}</label>
                    </div>
                    <div>
                        <input type="text" id="user.attributes.country" class="${properties.kcInputClass!}" name="user.attributes.country"
                               value="${(register.formData['user.attributes.country']!'')}"
                               aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>"/>

                        <#if messagesPerField.existsError('country')>
                            <span id="input-error-country" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('country'))?no_esc}
                        </span>
                        </#if>
                    </div>
                </div>
                <#if !realm.registrationEmailAsUsername>
                    <div class="${properties.kcFormGroupClass!} ${properties.kcInputRegisterWrapperClass!}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="text" id="username" class="${properties.kcInputClass!}" name="username"
                                   value="${(register.formData.username!'')}" autocomplete="username"
                                   aria-invalid="<#if messagesPerField.existsError('username')>true</#if>"/>

                            <#if messagesPerField.existsError('username')>
                                <span id="input-error-username" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('username'))?no_esc}
                            </span>
                            </#if>
                        </div>
                    </div>
                </#if>

                <#if passwordRequired??>
                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="password" id="password" class="${properties.kcInputClass!}" name="password"
                                   autocomplete="new-password"
                                   aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>"
                            />

                            <#if messagesPerField.existsError('password')>
                                <span id="input-error-password" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password'))?no_esc}
                            </span>
                            </#if>
                        </div>
                    </div>

                    <div class="${properties.kcFormGroupClass!}">
                        <div class="${properties.kcLabelWrapperClass!}">
                            <label for="password-confirm"
                                   class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                        </div>
                        <div class="${properties.kcInputWrapperClass!}">
                            <input type="password" id="password-confirm" class="${properties.kcInputClass!}"
                                   name="password-confirm"
                                   aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>"
                            />

                            <#if messagesPerField.existsError('password-confirm')>
                                <span id="input-error-password-confirm" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                            </span>
                            </#if>
                        </div>
                    </div>
                </#if>

                <#if recaptchaRequired??>
                    <div class="form-group">
                        <div class="${properties.kcInputWrapperClass!}">
                            <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                        </div>
                    </div>
                </#if>
            </section>
            <section id="content2">
                dzdazdazadz
            </section>
            <section id="content3">
            </section>


            <div class="${properties.kcFormGroupClass!}">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <span><a href="${url.loginUrl}">${kcSanitize(msg("backToLogin"))?no_esc}</a></span>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                           type="submit" value="${msg("doRegister")}"/>
                </div>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>