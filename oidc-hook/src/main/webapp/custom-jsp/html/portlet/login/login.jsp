<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@page import="com.liferay.portal.util.PortalUtil"%>
<%@ include file="/html/portlet/login/init.jsp"%>

<c:choose>
	<c:when test="<%=themeDisplay.isSignedIn()%>">

		<%
			String signedInAs = HtmlUtil.escape(user.getFullName());

					if (themeDisplay.isShowMyAccountIcon() && (themeDisplay.getURLMyAccount() != null)) {
						String myAccountURL = String.valueOf(themeDisplay.getURLMyAccount());

						if (PropsValues.DOCKBAR_ADMINISTRATIVE_LINKS_SHOW_IN_POP_UP) {
							signedInAs = "<a class=\"signed-in\" href=\"javascript:Liferay.Util.openWindow({dialog: {destroyOnHide: true}, title: '"
									+ HtmlUtil.escapeJS(LanguageUtil.get(pageContext, "my-account")) + "', uri: '"
									+ HtmlUtil.escapeJS(myAccountURL) + "'});\">" + signedInAs + "</a>";
						} else {
							myAccountURL = HttpUtil.setParameter(myAccountURL, "controlPanelCategory",
									PortletCategoryKeys.MY);

							signedInAs = "<a class=\"signed-in\" href=\"" + HtmlUtil.escape(myAccountURL) + "\">"
									+ signedInAs + "</a>";
						}
					}
		%>

		<%=LanguageUtil.format(pageContext, "you-are-signed-in-as-x", signedInAs, false)%>

		<%
			String logoutURL = PropsUtil.get("openidconnect.logout-url");
					logoutURL = HttpUtil.setParameter(logoutURL, "redirect_uri",
							PortalUtil.getPortalURL(request) + "/c/portal/logout");
		%>
		<div>
			<input type="button" class="btn btn-primary" value="Sign out" onclick="window.location.href = '/c/portal/logout';" />
			<input type="button" class="btn btn-primary" value="Full sign out" onclick="window.location.href = '<%=logoutURL%>';" />
		</div>

		<%
			String accessToken = (String) request.getSession().getAttribute("LIFERAY_SHARED_AccessToken");
		%>
		<div>
			<br />

			<div>
				<span id="tokenToggler">View token ></span> &nbsp;&nbsp; <span id="tokenHolder" class="hidden"><%=accessToken%></span>
			</div>

			<br />

			<div>
				testURL = 
				<input type="text" style="width: 400px;" name="testURL" id="testURL" value="http://localhost:8080/poc-spring-security-jwt/token" />
				<br />
				<input id="testToken" class="btn btn-primary" type="button" value="Go Test token!" />
			</div>
		</div>
		<div id="container">
			<ul>
				<li>Service API conversation will appear here (with decoded token).</li>
			</ul>
		</div>

		<script>
		YUI().use("io-base", "node",
		
		    function(Y) {
		
				let accessToken = '<%=accessToken%>';

				//Get a reference to the DIV that we are using
		        //to report results.
		        var b = Y.one('#tokenToggler'),
		        	t = Y.one('#tokenHolder'),
		        	d = Y.one('#container'),
		        	u = Y.one('#testURL'),
		            gStr = '',
		            tStr = '',
		            state;
		
				b.on('click', (e) => {
					t.toggleClass('hidden');
				});
				
		        /* global listener object */
		        var gH = {
		            write: function(s, args) {
		                     gStr += "ID: " + s;
		                     if (args) {
		                        gStr += " " + "The globally-defined arguments are: " + args;
		                     }
		                     gStr += "<br>";
		            },
		            start: function(id) {
		                     // When transaction listeners are handled, its user-defined arguments
		                     // are accessible in the arguments collection.  The following detection
		                     // logic determines whether the output should account for transaction
		                     // arguments.
		                     args = state === 'global' ? arguments[1] : arguments[2];
		                     this.write(id + ": Global Event Start.", args);
		            },
		            complete: function(id, o) {
		                     args = state === 'global' ? arguments[2] : arguments[3];
		                     this.write(id + ": Global Event Complete.  The status code is: " + o.status + ".", args);
		            },
		            success: function(id, o) {
		                      args = state === 'global' ? arguments[2] : arguments[3];
		                      this.write(id + ": Global Event Success.  The response is: " + o.responseText + ".", args);
		            },
		            failure: function(id, o) {
		                      args = state === 'global' ? arguments[2] : arguments[3];
		                      this.write(o + ": Global Event Failure.  The status text is: " + o.statusText + ".", args);
		            },
		            end: function(id) {
		                     args = state === 'global' ? arguments[1] : arguments[2];
		                     this.write(id + ": Global Event End.", args);
		                     if (state === 'global') {
		                         flush(gStr);
		                     }
		            }
		        };
		        /* end global listener object */
		
		        /* transaction event object */
		        var tH = {
		            write: function(s, args, addBR) {
		                     tStr += "ID " + s;
		                     if (args) {
		                        tStr += " " + "The arguments are: " + args;
		                     }
		                     addBR = addBR || 0;
		                     if (addBR >= 0) {
			                     tStr += "<br>";
		                     }
		                     if (addBR >= 1) {
			                     tStr += "<br>";
		                     }
		                   },
		            start: function(id, args) {
		                     this.write(id + ": Transaction Event Start.", args.start);
		                   },
		            complete: function(id, o, args) {
		                        this.write(id + ": Transaction Event Complete.  The status code is: " + o.status + ".", args.complete);
		                   },
		            success: function(id, o, args) {
		                       this.write(id + ": Transaction Event Success.  The response is: <br/><div style=\"padding-left:2em;\">" + o.responseText + "</div>", args.success, -1);
		                     },
		            failure: function(id, o, args) {
		                       this.write(id + ": Transaction Event Failure.  The status text is: " + o.statusText + ".", args.failure);
		                     },
		            end: function(id, args) {
		                     this.write(id + ": Transaction Event End.", args.end, 1);
		                     flush(gStr + tStr);
		            }
		        };
		        /* end transaction event object */
		
		        /* Output the results to the DIV container */
		        function flush(s) {
		            d.set("innerHTML", s);
		            if (state === 'global') {
		                gStr = '';
		            }
		            else {
		                gStr = '';
		                tStr = '';
		            }
		        }
		
		        /* attach global listeners */
		        Y.on('io:start', gH.start, gH, '','global foo');
		        Y.on('io:complete', gH.complete, gH, '','global bar');
		        Y.on('io:success', gH.success, gH, '','global baz');
		        Y.on('io:failure', gH.failure, gH);
		        Y.on('io:end', gH.end, gH, '', 'global boo');
		        /* end global listener binding */
		
		        /* configuration object for transactions */
		        var cfg = {
		            on: {
		                start: tH.start,
		                complete: tH.complete,
		                success: tH.success,
		                failure: tH.failure,
		                end: tH.end
		            },
		            context: tH,
	          		headers: { 'Authorization': 'Bearer ' + accessToken},
		            arguments: {}/*
		                       start: 'foo',
		                       complete: 'bar',
		                       success: 'baz',
		                       failure: 'Oh no!',
		                       end: 'boo'
		                       }*/
		        };
		        /* end configuration object */
		
		        function call(e, b) {
		            if (b) {
		                state = 'all';
		            }
		            else {
		                state = 'global';
		            }
		
		            Y.io(u.getDOMNode().value, cfg);
		        }

		        Y.on('click', call, "#testToken", Y, false);
		    });
		</script>
	</c:when>
	<c:otherwise>

		<div>
			<button class="btn btn-primary" onclick="window.location.href='/c/portal/login';">Direct SSO login</button>
		</div>
		<br />
		<div>or use classical login</div>
		<br />
		<%
			String redirect = ParamUtil.getString(request, "redirect");

					String login = LoginUtil.getLogin(request, "login", company);
					String password = StringPool.BLANK;
					boolean rememberMe = ParamUtil.getBoolean(request, "rememberMe");

					if (Validator.isNull(authType)) {
						authType = company.getAuthType();
					}
		%>

		<portlet:actionURL
			secure="<%=PropsValues.COMPANY_SECURITY_AUTH_REQUIRES_HTTPS || request.isSecure()%>"
			var="loginURL">
			<portlet:param name="struts_action" value="/login/login" />
		</portlet:actionURL>

		<aui:form action="<%=loginURL%>"
			autocomplete='<%=PropsValues.COMPANY_SECURITY_LOGIN_FORM_AUTOCOMPLETE ? "on" : "off"%>'
			cssClass="sign-in-form" method="post" name="fm"
			onSubmit="event.preventDefault();">
			<aui:input name="saveLastPath" type="hidden" value="<%=false%>" />
			<aui:input name="redirect" type="hidden" value="<%=redirect%>" />
			<aui:input name="doActionAfterLogin" type="hidden"
				value="<%=portletName.equals(PortletKeys.FAST_LOGIN) ? true : false%>" />

			<c:choose>
				<c:when test='<%=SessionMessages.contains(request, "userAdded")%>'>

					<%
						String userEmailAddress = (String) SessionMessages.get(request, "userAdded");
											String userPassword = (String) SessionMessages.get(request, "userAddedPassword");
					%>

					<div class="alert alert-success">
						<c:choose>
							<c:when
								test="<%=company.isStrangersVerify() || Validator.isNull(userPassword)%>">
								<%=LanguageUtil.get(pageContext, "thank-you-for-creating-an-account")%>

								<c:if test="<%=company.isStrangersVerify()%>">
									<%=LanguageUtil.format(pageContext,
													"your-email-verification-code-has-been-sent-to-x",
													userEmailAddress)%>
								</c:if>
							</c:when>
							<c:otherwise>
								<%=LanguageUtil.format(pageContext,
												"thank-you-for-creating-an-account.-your-password-is-x", userPassword,
												false)%>
							</c:otherwise>
						</c:choose>

						<c:if
							test="<%=PrefsPropsUtil.getBoolean(company.getCompanyId(),
											PropsKeys.ADMIN_EMAIL_USER_ADDED_ENABLED)%>">
							<%=LanguageUtil.format(pageContext, "your-password-has-been-sent-to-x",
											userEmailAddress)%>
						</c:if>
					</div>
				</c:when>
				<c:when
					test='<%=SessionMessages.contains(request, "userPending")%>'>

					<%
						String userEmailAddress = (String) SessionMessages.get(request, "userPending");
					%>

					<div class="alert alert-success">
						<%=LanguageUtil.format(pageContext,
										"thank-you-for-creating-an-account.-you-will-be-notified-via-email-at-x-when-your-account-has-been-approved",
										userEmailAddress)%>
					</div>
				</c:when>
			</c:choose>

			<liferay-ui:error exception="<%=AuthException.class%>"
				message="authentication-failed" />
			<liferay-ui:error exception="<%=CompanyMaxUsersException.class%>"
				message="unable-to-login-because-the-maximum-number-of-users-has-been-reached" />
			<liferay-ui:error
				exception="<%=CookieNotSupportedException.class%>"
				message="authentication-failed-please-enable-browser-cookies" />
			<liferay-ui:error exception="<%=NoSuchUserException.class%>"
				message="authentication-failed" />
			<liferay-ui:error exception="<%=PasswordExpiredException.class%>"
				message="your-password-has-expired" />
			<liferay-ui:error exception="<%=UserEmailAddressException.class%>"
				message="authentication-failed" />
			<liferay-ui:error exception="<%=UserLockoutException.class%>"
				message="this-account-has-been-locked" />
			<liferay-ui:error exception="<%=UserPasswordException.class%>"
				message="authentication-failed" />
			<liferay-ui:error exception="<%=UserScreenNameException.class%>"
				message="authentication-failed" />

			<aui:fieldset>

				<%
					String loginLabel = null;

									if (authType.equals(CompanyConstants.AUTH_TYPE_EA)) {
										loginLabel = "email-address";
									} else if (authType.equals(CompanyConstants.AUTH_TYPE_SN)) {
										loginLabel = "screen-name";
									} else if (authType.equals(CompanyConstants.AUTH_TYPE_ID)) {
										loginLabel = "id";
									}
				%>

				<aui:input
					autoFocus="<%=windowState.equals(LiferayWindowState.EXCLUSIVE)
										|| windowState.equals(WindowState.MAXIMIZED)%>"
					cssClass="clearable" label="<%=loginLabel%>" name="login"
					showRequiredLabel="<%=false%>" type="text" value="<%=login%>">
					<aui:validator name="required" />
				</aui:input>

				<aui:input name="password" showRequiredLabel="<%=false%>"
					type="password" value="<%=password%>">
					<aui:validator name="required" />
				</aui:input>

				<span id="<portlet:namespace />passwordCapsLockSpan"
					style="display: none;"><liferay-ui:message
						key="caps-lock-is-on" /></span>

				<c:if
					test="<%=company.isAutoLogin() && !PropsValues.SESSION_DISABLED%>">
					<aui:input checked="<%=rememberMe%>" name="rememberMe"
						type="checkbox" />
				</c:if>
			</aui:fieldset>

			<aui:button-row>
				<aui:button type="submit" value="sign-in" />
			</aui:button-row>
		</aui:form>

		<liferay-util:include page="/html/portlet/login/navigation.jsp" />

		<aui:script use="aui-base">
			var form = A.one(document.<portlet:namespace />fm);

			form.on(
				'submit',
				function(event) {
					var redirect = form.one('#<portlet:namespace />redirect');

					if (redirect) {
						var redirectVal = redirect.val();

						redirect.val(redirectVal + window.location.hash);
					}

					submitForm(form);
				}
			);

			var password = form.one('#<portlet:namespace />password');

			if (password) {
				password.on(
					'keypress',
					function(event) {
						Liferay.Util.showCapsLock(event, '<portlet:namespace />passwordCapsLockSpan');
					}
				);
			}
		</aui:script>
	</c:otherwise>
</c:choose>