// Local-only preview server. No application API, storage or outbound connections.
const http=require('node:http');
const fs=require('node:fs');
const path=require('node:path');
const base=__dirname;
const mime={'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.js':'text/javascript; charset=utf-8','.png':'image/png','.ttf':'font/ttf','.txt':'text/plain; charset=utf-8'};
const server=http.createServer((req,res)=>{
  let rel;
  try { rel=decodeURIComponent(new URL(req.url,'http://localhost').pathname); } catch {res.writeHead(400);res.end();return;}
  const file=path.resolve(base,'.'+(rel==='/'?'/index.html':rel));
  if(!file.startsWith(base+path.sep)){res.writeHead(403);res.end();return;}
  fs.stat(file,(err,stat)=>{
    if(err||!stat.isFile()){res.writeHead(404);res.end('Not found');return;}
    res.writeHead(200,{'Content-Type':mime[path.extname(file)]||'application/octet-stream','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});
    fs.createReadStream(file).pipe(res);
  });
});
server.listen(Number(process.env.PORT||8765),'127.0.0.1',()=>console.log('Plant detail preview: http://127.0.0.1:'+server.address().port));
