import json
# ---------- Verified anchors (Q2'26 release/call, Aug 6 2026) ----------
Q1,Q2=151.1,191.9; Q3g=(255,290); FY26=1100
Q3=sum(Q3g)/2; Q4=FY26-(Q1+Q2+Q3)
cash=508.8; debt_ex=92.8; shares=92.8   # Q3 guide diluted shares
conv=250.0   # PLACEHOLDER - convertible principal not verified
capexQ2=565.5

# implied 2026 quarterly path
print("Implied Q3 mid %.1f, Q4 implied by FY26 $1.1B = %.1f"%(Q3,Q4))

# ---------- Unit economics cross-checks ----------
asp16=(300+350)/2/0.5*1.0   # $300-350M per 500k units per month -> $/unit
print("1.6T ASP implied by mgmt ($300-350M/mo on 500k units): $%.0f (range %d-%d)"%(asp16,600,700))
m_1_6, m_800, m_lo = 164,217,90
units16=m_1_6/650*1e3; 
print("Mid-2027 mgmt monthly targets: 1.6T $164M (~%.0fk units @ $650), 800G $217M, 100G/400G $90M => $%dM/mo = $%.2fB annualised"%(units16,m_1_6+m_800+m_lo,(m_1_6+m_800+m_lo)*12/1e3))
# 800G+1.6T ceiling as multiple of Q4'26
ceiling_q=(m_1_6+m_800)*3
print("800G+1.6T mid-2027 quarterly run-rate implied: $%.0fM vs Q4'26 ~$330M => %.1fx"%(ceiling_q,ceiling_q/330))

# ---------- Scenarios ----------
S={
 "Bear":dict(rev=[1100,1750,2100,2300,2400,2500],ebit=[None,.12,.11,.10,.10,.10],capex=[1700,1100,500,350,300,300]),
 "Base":dict(rev=[1100,2600,3400,3900,4300,4600],ebit=[None,.20,.19,.18,.17,.16],capex=[1700,1500,800,600,550,550]),
 "Bull":dict(rev=[1100,3700,5000,5700,6200,6600],ebit=[None,.26,.25,.24,.23,.22],capex=[1700,1900,1200,900,800,800]),
}
tax=0.18; nwc_pct=0.22; life=0.11; legacyDA=50; roic=0.15
H1capex=250+capexQ2  # Q1 capex ASSUMED 250 (not verified)
def run(name,wacc=.11,g=.03,capex27=None,extra_shares=0,conv=conv,verbose=False):
    d=S[name]; rev=d["rev"]; ebit=d["ebit"]; capex=list(d["capex"])
    if capex27 is not None: capex[1]=capex27
    # H2'26
    q3ebit=Q3*0.30-75; q4=Q4; q4ebit=q4*0.325-80
    nopat_h2=(q3ebit+q4ebit)*(1-tax)
    capex_h2=capex[0]-H1capex
    da_h2=25+30
    dnwc_h2=nwc_pct*(q4*4-Q2*4)
    fcf_h2=nopat_h2+da_h2-dnwc_h2-capex_h2
    fcfs=[]; cum=capex[0]
    prev_rev=rev[0]
    for i in range(1,6):
        e=rev[i]*ebit[i]; nopat=e*(1-tax)
        da=legacyDA+life*(cum+0.5*capex[i])
        dn=nwc_pct*(rev[i]-prev_rev)
        f=nopat+da-dn-capex[i]
        fcfs.append(dict(year=2026+i,rev=rev[i],ebit=e,nopat=nopat,da=da,dnwc=dn,capex=capex[i],fcf=f))
        cum+=capex[i]; prev_rev=rev[i]
    pv=fcf_h2/(1+wacc)**0.25
    for i,f in enumerate(fcfs):
        pv+=f["fcf"]/(1+wacc)**(1+i)
    nopat31=fcfs[-1]["nopat"]
    tv=nopat31*(1+g)*(1-g/roic)/(wacc-g)
    pvtv=tv/(1+wacc)**5.5
    ev=pv+pvtv
    netdebt=debt_ex+conv-cash
    eq=ev-netdebt
    ps=eq/(shares+extra_shares)
    if verbose:
        print(f"\n{name}: H2'26 FCF {fcf_h2:,.0f}")
        for f in fcfs: print({k:round(v) for k,v in f.items()})
        print(f"PV explicit {pv:,.0f}  PV TV {pvtv:,.0f}  EV {ev:,.0f}  TV share {pvtv/ev:.0%}  netdebt {netdebt:,.0f}  equity {eq:,.0f}  per share {ps:,.1f}")
        cumf=fcf_h2+fcfs[0]["fcf"]
        print(f"Cumulative FCF H2'26+2027 = {cumf:,.0f}; cash 509 => external funding need ~{max(0,-(cumf)-cash+debt_ex*0):,.0f} (before min cash)")
    return ps,fcf_h2,fcfs,ev,pvtv
for n in S: run(n,verbose=True)

print("\n--- Sensitivity: value/share by WACC & scenario (g=3%) ---")
for w in (.10,.11,.13):
    print(w,[round(run(n,wacc=w)[0],1) for n in S])
print("--- terminal g 2% at 11% ---",[round(run(n,g=.02)[0],1) for n in S])
print("--- 2027 capex sensitivity (Base) ---")
for c in (800,1100,1500,1900,2200): print(c, round(run("Base",capex27=c)[0],1))
print("--- +15M extra shares (dilution) ---",[round(run(n,extra_shares=15)[0],1) for n in S])
print("--- convertible principal 0/250/500 (Base) ---",[round(run("Base",conv=c)[0],1) for c in (0,250,500)])
# weights
vals={n:run(n)[0] for n in S}
print("Prob-weighted 25/50/25:",round(.25*vals['Bear']+.5*vals['Base']+.25*vals['Bull'],1))
px=98.61
print("Market cap @%.2f x %.1fM = $%.2fB"%(px,shares,px*shares/1e3))
# reverse DCF: what base-like EBIT terminal margin for price=98.61 (scale base margins)
import copy
def scale_margin(k):
    S["Base"]["ebit"]=[None]+[m*k for m in [.20,.19,.18,.17,.16]]
    r=run("Base")[0]; return r
for k in (0.6,0.7,0.8,0.9,1.0):
    print("base margins x",k,"->",round(scale_margin(k),1))
S["Base"]["ebit"]=[None,.20,.19,.18,.17,.16]
# ASP erosion test: 2028+ revenue ~ if ASP -15%/yr and units flat
# Gross margin check on Q4 exit 32-33% ; opex 70-80/q
print("\nOpex run-rate $%dM/qtr = $%dM/yr; breakeven revenue at 33%% GM = $%.0fM/yr"%(75,300,300/.33))
# H2 capex funding gap
print("H1 capex (Q1 assumed 250 + Q2 565.5) = %.0f; H2 implied by FY26 1.7B = %.0f"%(H1capex,1700-H1capex))
# 800G/1.6T Q4 mix check
print("Q4'26: 800G+1.6T ~330 incl 1.6T 70-80 => 800G ~%.0f; 1.6T share of DC transceiver growth"%(330-75))
# ATM headroom
print("ATM: $600M program, $538.8M net raised => ~$%.0fM headroom (approx, gross vs net not reconciled)"%(600-538.8))

print("\n=========== EXIT-MULTIPLE CROSS-CHECK & REVERSE DCF ===========")
def exit_val(name,mult,wacc=.11,conv=conv):
    ps,fh2,fc,ev,pvtv=run(name,wacc=wacc,conv=conv)
    pv_expl=ev-pvtv
    # exit at end-2030 on 2030 NOPAT; drop 2031 flow
    pv_e=fh2/(1+wacc)**0.25+sum(f["fcf"]/(1+wacc)**(1+i) for i,f in enumerate(fc[:4]))
    tv=fc[3]["nopat"]*mult
    ev2=pv_e+tv/(1+wacc)**4.5
    eq=ev2-(debt_ex+conv-cash)
    return eq/shares
for m in (12,16,20,25):
    print("exit %dx 2030 NOPAT:"%m,[round(exit_val(n,m),1) for n in S])
# implied by market
px=98.61; eq=px*shares; ev_mkt=eq+(debt_ex+conv-cash)
print("Market EV ~ $%.0fM"%ev_mkt)
ps,fh2,fc,ev,pvtv=run("Base")
pv_expl=ev-pvtv
need_pvtv=ev_mkt-pv_expl
need_tv=need_pvtv*1.11**5.5
need_nopat=need_tv/(1.03*(1-.03/.15)/(.11-.03))
need_ebit=need_nopat/(1-tax)
print("Gordon route: need 2031 NOPAT $%.0fM => EBIT $%.0fM => revenue @22%% margin $%.1fB, @16%% margin $%.1fB (vs FY26 $1.1B, base 2031 $4.6B)"%(need_nopat,need_ebit,need_ebit/.22/1e3,need_ebit/.16/1e3))
# exit route @ 20x
pv_e=fh2/(1.11)**0.25+sum(f["fcf"]/(1.11)**(1+i) for i,f in enumerate(fc[:4]))
need_nopat30=(ev_mkt-pv_e)*1.11**4.5/20
print("Exit 20x route: need 2030 NOPAT $%.0fM => EBIT $%.0fM (base 2030 EBIT %.0f, bull %.0f)"%(need_nopat30,need_nopat30/(1-tax),fc[3]['ebit'],run('Bull')[2][3]['ebit']))
# probability-weighted at 16x exit
vals=[exit_val(n,16) for n in S]
print("16x exit, weights 25/50/25:",round(.25*vals[0]+.5*vals[1]+.25*vals[2],1))
# notes' FCF vs NOPAT sanity: notes base 2031 FCF 850 vs my NOPAT 604
print("Notes' 2031 FCF 850 vs model base 2031 NOPAT %.0f (FCF>NOPAT in perpetuity requires capex<D&A forever)"%fc[-1]['nopat'])
# Notes' DCF re-run with corrected inputs only (shares 92.8, net cash instead of 500 net debt)
def notes_dcf(f,w,g,sh,nd):
    pv=sum(f[i]/(1+w)**(i+1) for i in range(5)); tv=f[-1]*(1+g)/(w-g)/(1+w)**5
    return (pv+tv-nd)/sh
for label,sh,nd in [("notes inputs",81.6,500),("shares 92.8",92.8,500),("shares 92.8, net cash -166",92.8,-166),("shares 92.8, nd 500, +1.0B pre-2027 burn",92.8,500+1000)]:
    print(label,[round(notes_dcf(f,.11,.03,sh,nd),1) for f in ([250,450,600,750,850],[400,650,900,1100,1250])])
