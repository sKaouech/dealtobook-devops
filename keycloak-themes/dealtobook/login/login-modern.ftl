<#import "template.ftl" as layout>

<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        <!-- Logo moderne avec animation -->
        <div class="login-img-logo">
            <img src="${url.resourcesPath}/img/title_deal_to_book3.png" alt="DealToBook Logo"/>
        </div>
        
        <!-- Titre moderne avec gradient -->
        <div class="label">
            <i class="fas fa-sign-in-alt" style="margin-right: 0.5rem;"></i>
            ${msg("signin")}
        </div>
        
    <#elseif section = "form">
    <div id="kc-form">
        <div id="kc-form-wrapper">
        <#if realm.password>
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                
                <!-- Champ Username/Email moderne -->
                <div class="form-group">
                    <label for="username" class="form-label">
                        <i class="fas fa-user" style="margin-right: 0.5rem; color: var(--primary-color);"></i>
                        <#if !realm.loginWithEmailAllowed>
                            ${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>
                            ${msg("usernameOrEmail")}
                        <#else>
                            ${msg("email")}
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
                               placeholder="Votre identifiant"/>
                    <#else>
                        <input tabindex="1" 
                               id="username" 
                               class="pf-c-form-control" 
                               name="username" 
                               value="${(login.username!'')}" 
                               type="text" 
                               autofocus
                               autocomplete="username"
                               placeholder="<#if !realm.loginWithEmailAllowed>Nom d'utilisateur<#elseif !realm.registrationEmailAsUsername>Email ou nom d'utilisateur<#else>Adresse email</#if>"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>

                        <#if messagesPerField.existsError('username','password')>
                            <div class="pf-c-alert pf-m-danger pf-m-inline" style="margin-top: 0.5rem;">
                                <div class="pf-c-alert__icon">
                                    <i class="fas fa-exclamation-circle"></i>
                                </div>
                                <div class="pf-c-alert__title">
                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                </div>
                            </div>
                        </#if>
                    </#if>
                </div>

                <!-- Champ Password moderne -->
                <div class="form-group">
                    <label for="password" class="form-label">
                        <i class="fas fa-lock" style="margin-right: 0.5rem; color: var(--primary-color);"></i>
                        ${msg("password")}
                    </label>

                    <div style="position: relative;">
                        <input tabindex="2" 
                               id="password" 
                               class="pf-c-form-control" 
                               name="password" 
                               type="password" 
                               autocomplete="current-password"
                               placeholder="Votre mot de passe"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"/>
                        
                        <!-- Bouton pour afficher/masquer le mot de passe -->
                        <button type="button" 
                                onclick="togglePassword()" 
                                style="position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--text-secondary); cursor: pointer; padding: 0.25rem;">
                            <i id="password-toggle-icon" class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>

                <!-- Options du formulaire -->
                <div class="form-group" style="display: flex; justify-content: space-between; align-items: center; margin: 1.5rem 0;">
                    <#if realm.rememberMe && !usernameEditDisabled??>
                        <div class="checkbox">
                            <input tabindex="3" 
                                   id="rememberMe" 
                                   name="rememberMe" 
                                   type="checkbox" 
                                   <#if login.rememberMe??>checked</#if>>
                            <label for="rememberMe">${msg("rememberMe")}</label>
                        </div>
                    <#else>
                        <div></div>
                    </#if>
                    
                    <#if realm.resetPasswordAllowed>
                        <a tabindex="5" href="${url.loginResetCredentialsUrl}" class="forgot-password-link">
                            ${msg("doForgotPassword")}
                        </a>
                    </#if>
                </div>

                <!-- Bouton de connexion moderne -->
                <div class="form-group">
                    <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                    <button tabindex="4"
                            class="pf-c-button pf-m-primary pf-m-block"
                            name="login" 
                            id="kc-login" 
                            type="submit">
                        <i class="fas fa-sign-in-alt" style="margin-right: 0.5rem;"></i>
                        ${msg("doLogIn")}
                    </button>
                </div>
            </form>
        </#if>
        </div>

        <!-- Connexion sociale moderne -->
        <#if realm.password && social.providers??>
            <div id="kc-social-providers">
                <div class="kc-social-section">
                    <span>ou connectez-vous avec</span>
                </div>
                
                <div style="display: grid; gap: 0.75rem; margin-top: 1rem;">
                    <#list social.providers as p>
                        <a id="social-${p.alias}"
                           class="pf-c-button pf-m-control social-login-btn"
                           type="button" 
                           href="${p.loginUrl}"
                           style="display: flex; align-items: center; justify-content: center; padding: 0.875rem;">
                            <#if p.iconClasses?has_content>
                                <i class="${p.iconClasses!}" style="margin-right: 0.75rem; font-size: 1.2rem;"></i>
                            </#if>
                            <span>${p.displayName!}</span>
                        </a>
                    </#list>
                </div>
            </div>
        </#if>

    </div>
    
    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">
                <div id="kc-registration">
                    <!-- Message d'inscription moderne -->
                    <div style="text-align: center; margin-bottom: 1.5rem; padding: 1rem; background: rgba(255, 255, 255, 0.1); border-radius: 12px; backdrop-filter: blur(10px);">
                        <p style="color: var(--text-secondary); margin: 0 0 1rem 0; font-size: 0.95rem;">
                            Pas encore de compte ?
                        </p>
                        <a href="${url.registrationUrl}" 
                           class="pf-c-button pf-m-secondary"
                           style="background: var(--white); color: var(--primary-color); border: none; border-radius: 8px; padding: 0.75rem 1.5rem; text-decoration: none; font-weight: 600; transition: var(--transition);">
                            <i class="fas fa-user-plus" style="margin-right: 0.5rem;"></i>
                            ${msg("doRegister")}
                        </a>
                    </div>

                    <!-- Boutons d'inscription par type -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 0.75rem;">
                        <a class="register-button" href="https://administration-dev.dealtobook.com/register/client">
                            <div class="client-register-icon"></div>
                            <div class="register-button-title">${msg("doRegisterClient")}</div>
                        </a>
                        <a class="register-button" href="https://administration-dev.dealtobook.com/register/provider">
                            <div class="provider-register-icon"></div>
                            <div class="register-button-title">${msg("doRegisterProvider")}</div>
                        </a>
                        <a class="register-button" href="https://administration-dev.dealtobook.com/register/agency">
                            <div class="agency-register-icon"></div>
                            <div class="register-button-title">${msg("doRegisterAgency")}</div>
                        </a>
                    </div>
                </div>
            </div>
        </#if>
    </#if>

    <!-- Script pour le toggle du mot de passe -->
    <script>
        function togglePassword() {
            const passwordField = document.getElementById('password');
            const toggleIcon = document.getElementById('password-toggle-icon');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                toggleIcon.className = 'fas fa-eye-slash';
            } else {
                passwordField.type = 'password';
                toggleIcon.className = 'fas fa-eye';
            }
        }

        // Animation d'entrée pour les éléments du formulaire
        document.addEventListener('DOMContentLoaded', function() {
            const formGroups = document.querySelectorAll('.form-group');
            formGroups.forEach((group, index) => {
                group.style.animationDelay = (index * 0.1) + 's';
            });
        });

        // Effet de focus amélioré
        document.querySelectorAll('input').forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });
    </script>

</@layout.registrationLayout>
