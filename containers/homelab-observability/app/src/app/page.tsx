"use client";

import { Activity, AlertTriangle, Bell, Box, Database, Clock3, Cpu, HardDrive, LayoutDashboard, Menu, Network, RefreshCw, Search, Server, ShieldCheck, Sparkles, X } from "lucide-react";
import { useState } from "react";

const nav = [["Overview",LayoutDashboard],["Nodes & workloads",Server],["Storage & network",Network],["Databases",Database],["Alerts",Bell]] as const;
const nodes = [
  ["k3s-control-01","control + compute","Healthy",42,71,62,"1.82","48d"],
  ["k3s-control-02","etcd","Healthy",18,39,31,"0.44","48d"],
  ["nas-01","storage","Warning",27,54,87,"0.91","92d"],
] as const;
const sources = [
  ["VictoriaMetrics","Healthy","18.2k samples/s","8s ago","ok"],
  ["VictoriaLogs","Healthy","1.4 GB/day","11s ago","ok"],
  ["PMM","Reachable","pmm.kien.cc","API token required","warn"],
  ["OpenSRE","Healthy","12 checks available","16s ago","ok"],
];
const alerts = [["Critical","PostgreSQL replication lag","postgresql-a4-stg","12m"],["Warning","Volume usage above 85%","nas-01 / data","34m"],["Info","Backup completed with warnings","velero-daily","2h"]];
const trends: Record<string,number[][]> = {
  CPU:[[30,35,32,40,38,45,42,49,44,42],[15,18,20,16,22,19,25,21,18,18],[21,25,23,29,26,31,24,28,26,27]],
  Memory:[[64,65,66,67,68,68,69,70,71,71],[35,35,36,36,37,38,38,39,39,39],[48,49,50,50,51,52,52,53,54,54]],
  Network:[[18,32,28,52,35,61,46,70,42,38],[8,12,10,16,12,19,14,22,13,11],[25,31,27,39,32,44,36,52,34,29]],
  "Storage I/O":[[22,30,26,38,31,45,34,51,37,33],[5,8,6,11,7,12,8,14,7,6],[35,44,39,56,47,68,52,72,58,49]],
};

function Bar({value,warn=false}:{value:number;warn?:boolean}) { return <div className="usage"><i><b className={warn?"warn":""} style={{width:`${value}%`}} /></i><span>{value}%</span></div> }
function Spark({values,color="#22d3ee"}:{values:number[];color?:string}) { const p=values.map((v,i)=>`${i/(values.length-1)*100},${38-v*.32}`).join(" "); return <svg className="spark" viewBox="0 0 100 40" preserveAspectRatio="none"><polyline points={p} fill="none" stroke={color} strokeWidth="2" vectorEffect="non-scaling-stroke"/></svg> }
function Chart({metric}:{metric:string}) { const colors=["#22d3ee","#818cf8","#34d399"]; return <div className="chart"><svg viewBox="0 0 900 210" preserveAspectRatio="none">{trends[metric].map((s,j)=><polyline key={j} points={s.map((v,i)=>`${i/(s.length-1)*900},${195-v*1.9}`).join(" ")} fill="none" stroke={colors[j]} strokeWidth="3" vectorEffect="non-scaling-stroke"/>)}</svg><div className="axis"><span>13:00</span><span>13:15</span><span>13:30</span><span>13:45</span><span>Now</span></div></div> }

export default function Home(){
  const [view,setView]=useState("Overview"),[metric,setMetric]=useState("CPU"),[menu,setMenu]=useState(false),[refresh,setRefresh]=useState(false),[investigate,setInvestigate]=useState(false);
  const reload=()=>{setRefresh(true);setTimeout(()=>setRefresh(false),900)};
  return <div className="shell">
    {menu&&<button className="overlay" aria-label="Close" onClick={()=>setMenu(false)}/>}<aside className={menu?"open":""}>
      <div className="brand"><em><Activity size={19}/></em><div><strong>Kino</strong><small>Observability</small></div><button onClick={()=>setMenu(false)}><X size={18}/></button></div>
      <div className="scope"><i className="dot ok"/><div><strong>Homelab</strong><small>Production cluster</small></div></div>
      <nav><small>Infrastructure</small>{nav.map(([label,Icon])=><button key={label} className={view===label?"active":""} onClick={()=>{setView(label);setMenu(false)}}><Icon size={18}/><span>{label}</span>{label==="Alerts"&&<b>3</b>}</button>)}</nav>
      <footer><ShieldCheck size={17}/><div><strong>Read-only mode</strong><small>No automatic remediation</small></div></footer>
    </aside>
    <div className="workspace"><header><button className="icon mobile" onClick={()=>setMenu(true)}><Menu size={18}/></button><div className="crumb"><span>Infrastructure</span> / <strong>{view}</strong></div><div className="actions"><button className="search"><Search size={15}/>Search resources <kbd>⌘ K</kbd></button><button className="time"><Clock3 size={15}/>Last 1 hour</button><label><i className="dot ok"/>Healthy · 18/20 checks</label><button className="icon" onClick={reload}><RefreshCw size={16} className={refresh?"spin":""}/></button></div></header>
      <main>{view!=="Overview"?<section className="empty"><Box/><small>Infrastructure</small><h1>{view}</h1><p>This view is next in the build queue. The shared navigation and status system are ready.</p><button onClick={()=>setView("Overview")}>Back to overview</button></section>:<>
        <div className="heading"><div><small>CLUSTER OVERVIEW</small><h1>Homelab cluster</h1><p>3 nodes · 42 workloads · updated {refresh?"just now":"18s ago"}</p></div><div><span><AlertTriangle size={15}/>3 active alerts</span><button onClick={()=>setInvestigate(true)}><Sparkles size={16}/>Investigate with OpenSRE</button></div></div>
        {investigate&&<div className="investigation"><Sparkles/><div><strong>OpenSRE investigation prepared</strong><small>Read-only context assembled. Execution will be enabled when credentials are configured.</small></div><button onClick={()=>setInvestigate(false)}><X size={16}/></button></div>}
        <section className="summaries"><article><div><span><Server/>Nodes</span><b className="good">All online</b></div><strong>3 <small>/ 3 healthy</small></strong><p>2 control plane · 1 storage</p></article><article><div><span><Box/>Workloads</span><b className="caution">2 degraded</b></div><strong>40 <small>running</small></strong><p>42 desired across 12 namespaces</p></article><article><div><span><Cpu/>CPU</span><b className="good">−4% vs 1h</b></div><strong>38<small>% used</small></strong><Spark values={[32,38,35,46,42,49,44,38]}/></article><article><div><span><Activity/>Memory</span><b>66.8%</b></div><strong>21.4 <small>/ 32 GB</small></strong><Spark values={[58,60,61,63,64,65,66,67]} color="#818cf8"/></article></section>
        <section className="primary"><article className="panel nodes"><div className="title"><div><h2>Node health</h2><p>Current resource pressure across the fleet</p></div><button>View nodes</button></div><div className="table"><table><thead><tr><th>Node</th><th>Status</th><th>CPU</th><th>Memory</th><th>Disk</th><th>Load</th><th>Uptime</th></tr></thead><tbody>{nodes.map(n=><tr key={n[0]}><td><strong>{n[0]}</strong><small>{n[1]}</small></td><td><span className={n[2]==="Warning"?"caution":""}><i className={`dot ${n[2]==="Healthy"?"ok":"warn"}`}/>{n[2]}</span></td><td><Bar value={n[3]}/></td><td><Bar value={n[4]}/></td><td><Bar value={n[5]} warn={n[5]>80}/></td><td>{n[6]}</td><td>{n[7]}</td></tr>)}</tbody></table></div></article>
          <article className="panel capacity"><div className="title"><div><h2>Capacity</h2><p>Cluster headroom</p></div><HardDrive/></div>{[["CPU",38,"10.1 cores available"],["Memory",67,"10.6 GB available"],["Storage",78,"416 GB available"]].map(([l,v,d])=><div className="cap" key={l}><div><strong>{l}</strong><span>{v}% used</span></div><Bar value={v as number} warn={l==="Storage"}/><p>{d}</p></div>)}<div className="warning"><AlertTriangle/><span><strong>nas-01 / data</strong> is above 85%</span></div></article></section>
        <section className="secondary"><article className="panel"><div className="title"><div><h2>Telemetry sources</h2><p>Integration health, separate from cluster health</p></div><Activity/></div><div className="sources">{sources.map(s=><div className="source" key={s[0]}><em><i className={`dot ${s[4]}`}/></em><div><strong>{s[0]}</strong><small>{s[2]}</small></div><div><strong className={s[4]}>{s[1]}</strong><small>{s[3]}</small></div></div>)}</div></article><article className="panel"><div className="title"><div><h2>Active alerts</h2><p>Sorted by severity and age</p></div><button>View all</button></div>{alerts.map(a=><div className="alert" key={a[1]}><b className={a[0].toLowerCase()}>{a[0]}</b><div><strong>{a[1]}</strong><small>{a[2]}</small></div><time>{a[3]}</time></div>)}</article></section>
        <section className="panel trends"><div className="title"><div><h2>Resource trends</h2><p>Fleet utilization · last 1 hour</p></div><div className="legend"><span><i/>k3s-control-01</span><span><i/>k3s-control-02</span><span><i/>nas-01</span></div></div><div className="tabs">{Object.keys(trends).map(t=><button className={metric===t?"active":""} key={t} onClick={()=>setMetric(t)}>{t}</button>)}</div><Chart metric={metric}/></section>
      </>}</main>
    </div>
  </div>
}
