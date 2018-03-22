/*
 * This file implements the mod-file for the monetary policy shock comparison between the 
 * EHL and SGU setups for a given Calvo wage parameter in Born/Pfeifer (2018):
 * "The New Keynesian Wage Phillips Curve: Calvo vs. Rotemberg". 
 * It contains the baseline New Keynesian model of Gal� (2015), Chapter 6 in linear form
 * with the EHL and SGU insurance schemes and Calvo and Rotemberg wage setting, while price
 * setting follows Calvo.
 *
 * THIS MOD-FILE REQUIRES DYNARE 4.5 OR HIGHER
 *
 * This implementation was written by Johannes Pfeifer. In case you spot mistakes,
 * email me at jpfeifer@gmx.de
 *
 * Please note that the following copyright notice only applies to this Dynare 
 * implementation of the model. 
 */

/*
 * Copyright (C) 2018 Johannes Pfeifer and Benjamin Born
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * It is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * For a copy of the GNU General Public License,
 * see <http://www.gnu.org/licenses/>.
 */


@#ifndef fixed_WPC_slope
    @#define fixed_WPC_slope=0
@#endif        

@#ifndef SGU_framework
    @#define SGU_framework=0
@#endif        

@#ifndef Calvo
    @#define Calvo=1
@#endif   

@#ifndef taxes
    @#define taxes=0
@#endif        


var pi_p        ${\pi^p}$               (long_name='price inflation')
    y_gap       ${\tilde y}$            (long_name='output gap')
    y_nat       ${y^{nat}}$             (long_name='natural output')      //(in contrast to the textbook defined in deviation from steady state)
    y           ${y}$                   (long_name='output')
    yhat        ${\hat y}$              (long_name='output deviation from steady state')
    r_nat       ${r^{nat}}$             (long_name='natural interest rate')
    r_real      ${r^r}$                 (long_name='real interest rate')     
    i           ${i}$                   (long_name='nominal interrst rate')
    n           ${n}$                   (long_name='hours worked')
    m_real      ${(m-p)}$                 (long_name='real money stock')
    m_growth_ann ${\Delta m}$           (long_name='money growth annualized')
    m_nominal   ${m}$                   (long_name='nominal money stock')
    nu          ${\nu}$                 (long_name='AR(1) monetary policy shock process')    
    a           ${a}$                   (long_name='AR(1) technology shock process')
    r_real_ann  ${r^{r,ann}}$           (long_name='annualized real interest rate')
    i_ann       ${i^{ann}}$             (long_name='annualized nominal interest rate')
    r_nat_ann   ${r^{nat,ann}}$         (long_name='annualized natural interest rate')
    pi_p_ann    ${\pi^{p,ann}}$         (long_name='annualized inflation rate')
    z           ${z}$                   (long_name='AR(1) preference shock process')
    p           ${p}$                   (long_name='price level')
    w           ${w}$                   (long_name='nominal wage')
    c           ${c}$                   (long_name='consumption')
    w_real      $\omega$                (long_name='real wage')
    w_gap       ${\tilde \omega}$       (long_name='real wage gap')
    pi_w        ${\pi^w}$               (long_name='wage inflation')
    w_nat       ${w^{nat}}$             (long_name='natural real wage')
    mu_p        ${\mu^p}$               (long_name='markup')
    pi_w_ann    ${\pi^{w,ann}}$         (long_name='annualized wage inflation rate')
;     

varexo  eps_a       ${\varepsilon_a}$   (long_name='technology shock')
        eps_nu      ${\varepsilon_\nu}$ (long_name='monetary policy shock')
        eps_z       ${\varepsilon_z}$   (long_name='preference shock innovation')
       ;

parameters alppha       ${\alpha}$     (long_name='capital share')
    betta               ${\beta}$       (long_name='discount factor')
    rho_a               ${\rho_a}$      (long_name='autocorrelation technology shock')
    rho_nu              ${\rho_{\nu}}$  (long_name='autocorrelation monetary policy shock')
    rho_z               ${\rho_{z}}$    (long_name='autocorrelation demand shock')
    siggma              ${\sigma}$      (long_name='inverse EIS')
    varphi              ${\varphi}$     (long_name='inverse Frisch elasticity')
    phi_pi              ${\phi_{\pi}}$  (long_name='inflation feedback Taylor Rule')
    phi_y               ${\phi_{y}}$    (long_name='output feedback Taylor Rule')
    eta                 ${\eta}$        (long_name='semi-elasticity of money demand')
    epsilon_p           ${\epsilon_p}$  (long_name='demand elasticity goods')
    theta_p             ${\theta_p}$    (long_name='Calvo parameter prices')
    epsilon_w           ${\epsilon_w}$  (long_name='demand elasticity labor services')
    @#if Calvo
        theta_w         ${\theta_w}$    (long_name='Calvo parameter wages')
    @#else
        phi_w           ${\phi_w}$      (long_name='Rotemberg parameter wages')
    @#endif
    tau                 ${\tau}$        (long_name='labor subsidy')
    lambda_w            ${\lambda_w}$   (long_name='Slope of the wage PC')
    tau_n_SS            ${bar {\tau^n}}$    (long_name='Steady state labor tax')
    ;
%----------------------------------------------------------------
% Parametrization, p. 67  and p. 113-115
%----------------------------------------------------------------
siggma = 1;
varphi=5;
phi_pi = 1.5;
phi_y  = 0.125;
theta_p=3/4;
rho_nu =0.5;
rho_z  = 0.5;
rho_a  = 0.9;
betta  = 0.99;
eta  =3.77; %footnote 11, p. 115
alppha=1/4;
epsilon_p=9;
tau=0; //1/epsilon_p;

epsilon_w=4.5;
@#if fixed_WPC_slope
    lambda_w=0.03;
@#else
    theta_w=3/4;
@#endif        
 
@#if taxes
    tau_n_SS=0.99;
@#else
    tau_n_SS=0;
@#endif

%----------------------------------------------------------------
% First Order Conditions
%----------------------------------------------------------------

model(linear); 
//Composite parameters
#Omega=(1-alppha)/(1-alppha+alppha*epsilon_p);              %defined on page 166
#psi_n_ya=(1+varphi)/(siggma*(1-alppha)+varphi+alppha);     %defined on page 171
#psi_n_wa=(1-alppha*psi_n_ya)/(1-alppha);                   %defined on page 171
#lambda_p=(1-theta_p)*(1-betta*theta_p)/theta_p*Omega;      %defined on page 166
#aleph_p=alppha*lambda_p/(1-alppha);                         %defined on page 172
#aleph_w=lambda_w*(siggma+varphi/(1-alppha));               %defined on page 172
[name='New Keynesian Phillips Curve eq. (18)']
pi_p=betta*pi_p(+1)+aleph_p*y_gap+lambda_p*w_gap;
[name='New Keynesian Wage Phillips Curve eq. (22)']
pi_w=betta*pi_w(+1)+aleph_w*y_gap-lambda_w*w_gap;
[name='Dynamic IS Curve eq. (22)']
y_gap=-1/siggma*(i-pi_p(+1)-r_nat)+y_gap(+1);
[name='Interest Rate Rule eq. (26)']
i=phi_pi*pi_p+phi_y*yhat+nu;
[name='Definition natural rate of interest eq. (24)']
r_nat=-siggma*psi_n_ya*(1-rho_a)*a+(1-rho_z)*z;
[name='Definition wage gap, eq (21)']
w_gap=w_gap(-1)+pi_w-pi_p-(w_nat-w_nat(-1));
[name='Definition natural wage, eq (16)']
w_nat=psi_n_wa*a;
[name='Definition markup']
mu_p=-alppha/(1-alppha)*y_gap-w_gap;
[name='Definition real wage gap, p. 171']
w_gap=w_real-w_nat;
[name='Definition real interest rate']
r_real=i-pi_p(+1);
[name='Definition natural output, eq. (20)']
y_nat=psi_n_ya*a;
[name='Definition output gap']
y_gap=y-y_nat;
[name='Monetary policy shock']
nu=rho_nu*nu(-1)+eps_nu;
[name='TFP shock']
a=rho_a*a(-1)+eps_a;
[name='Production function, p. 171']
y=a+(1-alppha)*n;
[name='Preference shock, p. 54']
z     = rho_z*z(-1) - eps_z;
[name='Money growth (derived from eq. (4))']
m_growth_ann=4*(y-y(-1)-eta*(i-i(-1))+pi_p);
[name='Real money demand (eq. 4)']
m_real=y-eta*i;
[name='Annualized nominal interest rate']
i_ann=4*i;
[name='Annualized real interest rate']
r_real_ann=4*r_real;
[name='Annualized natural interest rate']
r_nat_ann=4*r_nat;
[name='Annualized inflation']
pi_p_ann=4*pi_p;
[name='Annualized wage inflation']
pi_w_ann=4*pi_w;
[name='Output deviation from steady state']
yhat=y-steady_state(y);
[name='Definition price level']
pi_p=p-p(-1);
[name='resource constraint, eq. (12)']
y=c;
[name='definition real wage']
w_real=w-p;
[name='definition real wage']
m_nominal=m_real+p;
end;


%----------------------------------------------------------------
%  define shock variances
%---------------------------------------------------------------


shocks;
    var eps_nu = 0.25^2; //1 standard deviation shock of 25 basis points, i.e. 1 percentage point annualized
    var eps_a  = 1^2; //unit shock to technology
    var eps_z  = 1^2; //unit shock to technology
end;

%----------------------------------------------------------------
%  steady states: all 0 due to linear model
%---------------------------------------------------------------
steady_state_model;
@#if fixed_WPC_slope
    %keep fixed slope of WPC and compute parameters accordingly
    @#if SGU_framework
        @#if Calvo
            theta_w=get_Calvo_theta(lambda_w,epsilon_w,betta,varphi,1);
        @#else
            phi_w=(epsilon_w-1)*(1-tau_n_SS)/lambda_w*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w;     
        @#endif
    @#else
        @#if Calvo
            theta_w=get_Calvo_theta(lambda_w,epsilon_w,betta,varphi,0);
        @#else
            phi_w=(epsilon_w-1)*(1-tau_n_SS)/lambda_w*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w;     
        @#endif
    @#endif
@#else
    @#if SGU_framework
        %compute slope (and ) based on Calvo parameter 
        @#if Calvo
            lambda_w=(1-theta_w)*(1-betta*theta_w)/theta_w;
        @#else
            phi_w=(epsilon_w-1)/((1-theta_w)*(1-betta*theta_w))*(1-tau_n)*theta_w*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w;
            lambda_w=(epsilon_w-1)/phi_w*(1-tau_n)*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w;
        @#endif
    @#else
        @#if Calvo
            lambda_w=(1-theta_w)*(1-betta*theta_w)/(theta_w*(1+epsilon_w*varphi));
        @#else
            phi_w=(epsilon_w-1)/((1-theta_w)*(1-betta*theta_w))*(1-tau_n)*theta_w*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w*(1+epsilon_w*varphi);
            lambda_w=(epsilon_w-1)*(1-tau_n)/phi_w*(1-alppha)*(epsilon_p-1)/epsilon_p/tau_s_p*tau_s_w;
        @#endif
    @#endif
@#endif
end;

%----------------------------------------------------------------
% generate IRFs for monetary policy shock
%----------------------------------------------------------------
stoch_simul(order = 1,irf=15) y_gap pi_p_ann pi_w_ann w_real y n;