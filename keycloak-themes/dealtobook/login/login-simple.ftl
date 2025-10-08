<#import "template.ftl" as layout>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        <!-- Logo simple -->
        <div class="login-img-logo">
            <img src="${url.resourcesPath}/img/title_deal_to_book3.png" alt="DealToBook"/>
        </div>
        
        <!-- Titre simple -->
        <div class="label">
            <span class="icon-signin"></span>
            Sign in
        </div>
        
    <#elseif section = "form">
    <div id="kc-form">
        <div id="kc-form-wrapper">
        <#if realm.password>
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                
                <!-- Email/Username -->
                <div class="form-group">
                    <label for="username" class="form-label">
                        <#if !realm.loginWithEmailAllowed>
                            Username
                        <#elseif !realm.registrationEmailAsUsername>
                            Email or Username
                        <#else>
                            Email
                        </#if>
                    </label>

                    <#if usernameEditDisabled??>
                        <input tabindex="1" 
                               id="username" 
                               class="pf-c-form-control" 
                               name="username" 
                               value="${(login.username!'')}" 
                               type="text" 
                               disabled
                               placeholder="Enter your email"/>
                    <#else>
                        <input tabindex="1" 
                               id="username" 
                               class="pf-c-form-control" 
                               name="username" 
                               value="${(login.username!'')}" 
                               type="text" 
                               autofocus
                               autocomplete="username"
                               placeholder="<#if !realm.loginWithEmailAllowed>Enter your username<#elseif !realm.registrationEmailAsUsername>Enter your email or username<#else>Enter your email</#if>"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>

                        <#if messagesPerField.existsError('username','password')>
                            <div class="pf-c-alert" style="margin-top: 0.5rem;">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </div>
                        </#if>
                    </#if>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="password" class="form-label">Password</label>

                    <div style="position: relative;">
                        <input tabindex="2" 
                               id="password" 
                               class="pf-c-form-control" 
                               name="password" 
                               type="password" 
                               autocomplete="current-password"
                               placeholder="Enter your password"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                        
                        <!-- Toggle password -->
                        <button type="button" 
                                class="password-toggle"
                                onclick="togglePassword()">
                            <span id="password-toggle-icon" class="icon-eye"></span>
                        </button>
                    </div>
                </div>

                <!-- Options -->
                <div class="form-options">
                    <#if realm.rememberMe && !usernameEditDisabled??>
                        <div class="checkbox">
                            <input tabindex="3" 
                                   id="rememberMe" 
                                   name="rememberMe" 
                                   type="checkbox" 
                                   <#if login.rememberMe??>checked</#if>>
                            <label for="rememberMe">Remember me</label>
                        </div>
                    <#else>
                        <div></div>
                    </#if>
                    
                    <#if realm.resetPasswordAllowed>
                        <a tabindex="5" href="${url.loginResetCredentialsUrl}">
                            Forgot Password?
                        </a>
                    </#if>
                </div>

                <!-- Submit button -->
                <div class="form-group">
                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <button tabindex="4"
                            class="pf-c-button pf-m-primary"
                            name="login" 
                            id="kc-login" 
                            type="submit">
                        Sign In
                    </button>
                </div>
            </form>
        </#if>
        </div>

        <!-- Social login (if enabled) -->
        <#if realm.password && social.providers??>
            <div id="kc-social-providers" style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid var(--border-color); text-align: center;">
                <p style="color: var(--text-light); margin-bottom: 1rem; font-size: 0.9rem;">Or continue with</p>
                
                <div style="display: flex; gap: 0.5rem; justify-content: center; flex-wrap: wrap;">
                    <#list social.providers as p>
                        <a id="social-${p.alias}"
                           class="pf-c-button pf-m-control"
                           href="${p.loginUrl}"
                           style="padding: 0.75rem 1rem; border: 1px solid var(--border-color); border-radius: var(--border-radius); background: var(--white); color: var(--text-dark); text-decoration: none; transition: var(--transition);">
                            ${p.displayName!}
                        </a>
                    </#list>
                </div>
            </div>
        </#if>

    </div>
    
    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">
                <p style="color: var(--text-light); margin-bottom: 1rem;">
                    Don't have an account?
                </p>
                <a href="${url.registrationUrl}" 
                   style="background: var(--primary-green); color: var(--white); padding: 0.75rem 1.5rem; border-radius: var(--border-radius); text-decoration: none; font-weight: 600; display: inline-block;">
                    Create Account
                </a>

                <!-- Registration types -->
                <div style="display: flex; gap: 0.5rem; justify-content: center; margin-top: 1.5rem; flex-wrap: wrap;">
                    <a class="register-button" href="https://administration-dev.dealtobook.com/register/client">
                        <div style="text-align: center;">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">👤</div>
                            <div class="register-button-title">Client</div>
                        </div>
                    </a>
                    <a class="register-button" href="https://administration-dev.dealtobook.com/register/provider">
                        <div style="text-align: center;">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">🏢</div>
                            <div class="register-button-title">Provider</div>
                        </div>
                    </a>
                    <a class="register-button" href="https://administration-dev.dealtobook.com/register/agency">
                        <div style="text-align: center;">
                            <div style="font-size: 1.5rem; margin-bottom: 0.5rem;">🏛️</div>
                            <div class="register-button-title">Agency</div>
                        </div>
                    </a>
                </div>
            </div>
        </#if>
    </#if>

    <!-- Simple JavaScript -->
    <script>
        function togglePassword() {
            const passwordField = document.getElementById('password');
            const toggleIcon = document.getElementById('password-toggle-icon');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                toggleIcon.className = 'icon-eye-slash';
            } else {
                passwordField.type = 'password';
                toggleIcon.className = 'icon-eye';
            }
        }

        // Simple form validation feedback
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('kc-form-login');
            if (form) {
                form.addEventListener('submit', function() {
                    const button = document.getElementById('kc-login');
                    if (button) {
                        button.innerHTML = 'Signing in...';
                        button.disabled = true;
                    }
                });
            }
        });
    </script>

</@layout.registrationLayout>
