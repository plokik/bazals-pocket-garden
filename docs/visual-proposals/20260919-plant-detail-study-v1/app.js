'use strict';
// Isolated presentation state. No storage, network requests or game-save access.
const $ = id => document.getElementById(id);
const initialState = () => ({moisture:48, air:22, doses:2, light:false});
let state = initialState();
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
let paused = reducedMotion.matches;
let feedbackTimer, effectTimer, waterTimer;
let windUntil = 0;
let lastFrame = 0;
let motionTime = 0;
let paintedMotion = NaN;
let paintedWind = NaN;
const scene = $('greenhouse');
const dialog = $('info-dialog');
const icon = name => `<svg class="icon" aria-hidden="true"><use href="#i-${name}"/></svg>`;

function announce(text, note) {
  clearTimeout(feedbackTimer);
  $('care-feedback').textContent = text;
  $('care-feedback').classList.add('visible');
  if (note) $('garden-note').textContent = note;
  feedbackTimer = setTimeout(() => $('care-feedback').classList.remove('visible'), 3400);
}
function render() {
  $('moisture-value').innerHTML = `${state.moisture}<span> %</span>`;
  $('moisture-note').textContent = state.moisture >= 64 ? 'Příjemně vlhká' : 'Mírně suchá';
  $('air-caption').textContent = `Proudění ${state.air} %`;
  $('ventilate').setAttribute('aria-label', `Vyvětrat. Proudění ${state.air} procent`);
  $('light-caption').textContent = state.light ? 'Zapnuto' : 'Vypnuto';
  $('light').setAttribute('aria-pressed', String(state.light));
  $('food-caption').textContent = state.doses === 0 ? 'Bez hnojiva' : state.doses === 1 ? '1 dávka' : '2 dávky';
  $('fertilize').disabled = state.doses === 0;
  $('water').disabled = state.moisture >= 64;
  $('water-caption').textContent = state.moisture >= 64 ? 'Zalito' : '120 ml';
  $('water').setAttribute('aria-label', state.moisture >= 64 ? 'Zalito. Půda je nyní dostatečně vlhká' : 'Zalít 120 mililitry');
  $('ventilate').disabled = state.air === 100;
  $('conditions-value').innerHTML = `${Math.min(96, 78 + Math.round((state.air-22)*.14) + (state.light?3:0) + (2-state.doses)*2)}<span> %</span>`;
  scene.classList.toggle('lamp-on', state.light);
}
$('water').addEventListener('click', () => {
  state.moisture = 64;
  render();
  if (!paused && !reducedMotion.matches) {
    $('water-drops').replaceChildren();
    for (let i=0;i<9;i++) {
      const drop = document.createElement('i');
      drop.style.setProperty('--x', `${35+(i*7)%31}%`);
      drop.style.setProperty('--delay', `${i*70}ms`);
      $('water-drops').append(drop);
    }
    clearTimeout(waterTimer);
    waterTimer = setTimeout(() => $('water-drops').replaceChildren(), 1800);
  }
  announce('Zalito · vlhkost 48 → 64 %', 'Půda je teď příjemně vlhká. S další zálivkou počkej.');
});
$('ventilate').addEventListener('click', () => {
  const before = state.air;
  state.air = Math.min(100, state.air+26);
  render();
  windUntil = performance.now()+2800;
  scene.classList.remove('venting');
  void scene.offsetWidth;
  if (!paused && !reducedMotion.matches) scene.classList.add('venting');
  clearTimeout(effectTimer);
  effectTimer = setTimeout(() => scene.classList.remove('venting'), 2850);
  announce(`Čerstvý vzduch · ${before} → ${state.air} %`, state.air === 100 ? 'Proudění je na maximu. Bazalka má dostatek čerstvého vzduchu.' : 'Listy se zavlnily v čerstvém vzduchu.');
});
$('light').addEventListener('click', () => {
  state.light = !state.light;
  render();
  announce(state.light ? 'Přisvětlení zapnuto' : 'Přisvětlení vypnuto', state.light ? 'Na parapet dopadá více teplého světla.' : 'Bazalce teď svítí jen ranní slunce.');
});
$('fertilize').addEventListener('click', () => {
  if (state.doses <= 0) return;
  state.doses--;
  render();
  announce('Přihnojeno · 1 dávka', 'Výživa je v půdě. Dej bazalce čas na další růst.');
});

function renderMotion() {
  document.body.classList.toggle('motion-paused', paused);
  $('motion-toggle').setAttribute('aria-pressed', String(paused));
  $('motion-toggle').querySelector('span').textContent = paused ? 'Zapnout pohyb' : 'Pozastavit pohyb';
  scene.setAttribute('aria-label', `Malovaná bazalka v tyrkysovém květináči na slunném parapetu.${paused ? ' Pohyb je pozastavený.' : ' Listy se jemně pohybují.'}`);
}
$('motion-toggle').addEventListener('click', () => { paused = !paused; renderMotion(); });
reducedMotion.addEventListener('change', event => { paused=event.matches; renderMotion(); });
$('reset').addEventListener('click', () => {
  clearTimeout(feedbackTimer);clearTimeout(effectTimer);clearTimeout(waterTimer);
  state=initialState();windUntil=0;scene.classList.remove('venting');
  $('water-drops').replaceChildren();
  $('care-feedback').classList.remove('visible');
  $('garden-note').textContent='Každý nový lístek začíná trochou péče.';
  render();
  announce('Ukázka obnovena');
});

const content = {
  help: () => ['Chvilka pro bazalku', '<p>Vlhkost říká, kolik vody má půda. Zdraví ukazuje kondici rostliny. Podmínky shrnují její prostředí.</p><p><strong>Zalít</strong> zvlhčí půdu. <strong>Vyvětrat</strong> zlepší proudění vzduchu — jeho procento vidíš přímo na tlačítku.</p><p>Klepnutím na jednotlivé ukazatele se dozvíš více.</p>'],
  herbarium: () => ['Bazalka pravá', '<p class="species">Ocimum basilicum</p><p>Voňavá společnice slunných parapetů. Její měkké zelené listy rostou v párech a mají výraznou, svěží vůni.</p><dl><dt>Světlo</dt><dd>Světlé místo</dd><dt>Zálivka</dt><dd>Přiměřeně vlhká půda</dd><dt>Vzduch</dt><dd>Jemné proudění</dd></dl><p>Pravidelná péče pomůže rostlině dorůst do další fáze.</p>'],
  moisture: () => ['Vlhkost půdy', `<p>Aktuálně <strong>${state.moisture} %</strong>. ${state.moisture >= 64 ? 'Půda je po zálivce dostatečně vlhká. Další vodu zatím nepotřebuje.' : 'Půda začíná osychat. Malá zálivka jí dodá vodu.'}</p><p>Vlhkost a proudění jsou různé údaje. Větrání pomáhá půdě postupně vysychat.</p>`],
  health: () => ['Zdravá a spokojená', '<p>Zdraví bazalky je <strong>91 %</strong>. Je v dobré kondici a její listy mají svěží barvu.</p><p>Zdraví se mění postupně podle péče. Jedno kliknutí jej nezvýší okamžitě.</p>'],
  conditions: () => ['Jak se jí u tebe daří', `<dl><dt>Proudění vzduchu</dt><dd>${state.air} %</dd><dt>Vlhkost půdy</dt><dd>${state.moisture} %</dd><dt>Přisvětlení</dt><dd>${state.light?'Zapnuto':'Vypnuto'}</dd></dl><p>Podmínky shrnují více vlivů. Procento proudění proto sleduj přímo u tlačítka Vyvětrat.</p>`],
  plants: () => ['Moje rostliny', `<button class="plant-choice" id="choose-basil">${icon('pot')}<span><strong>Bazalka</strong><small>Květináč 01 · daří se jí</small></span>${icon('check')}</button>`]
};
document.querySelectorAll('[data-dialog]').forEach(button => button.addEventListener('click', () => {
  const [title, body] = content[button.dataset.dialog]();
  $('dialog-title').textContent=title;
  $('dialog-content').innerHTML=body;
  $('dialog-kicker').textContent=button.dataset.dialog==='plants'?'TVŮJ KOUSEK ZAHRADY':'BAZALŮV ZÁPISNÍK';
  $('choose-basil')?.addEventListener('click', () => dialog.close());
  dialog.showModal();
}));
$('close-dialog').addEventListener('click', () => dialog.close());
$('dialog-done').addEventListener('click', () => dialog.close());
dialog.addEventListener('click', event => { if(event.target===dialog) { const rect=dialog.getBoundingClientRect(); if(event.clientX<rect.left||event.clientX>rect.right||event.clientY<rect.top||event.clientY>rect.bottom) dialog.close(); } });

// Runtime canopy deformation: the painted source is untouched; the pot is anchored.
// Remove the white matte at render time so window bars cannot show through leaves.
// No raster source or game asset is modified by this preview.
const canvas=$('plant-canvas');
const ctx=canvas.getContext('2d');
const plant=new Image();
const sprite=document.createElement('canvas');
let ready=false;
plant.onload=()=>{
  sprite.width=plant.width;sprite.height=plant.height;
  const painter=sprite.getContext('2d');
  painter.drawImage(plant,0,0);
  const pixels=painter.getImageData(0,0,sprite.width,sprite.height);
  for(let i=0;i<pixels.data.length;i+=4){
    const alpha=Math.min(1,(255-Math.min(pixels.data[i],pixels.data[i+1],pixels.data[i+2]))/35);
    if(alpha<1){
      for(let c=0;c<3;c++) pixels.data[i+c]=alpha>0 ? Math.max(0,(pixels.data[i+c]-255*(1-alpha))/alpha) : 0;
      pixels.data[i+3]=Math.round(alpha*255);
    }
  }
  painter.putImageData(pixels,0,0);
  ready=true;
};
plant.onerror=()=>{canvas.hidden=true;$('plant-fallback').hidden=false;};
plant.src='assets/basil-painted-v1.png';
function draw(now) {
  requestAnimationFrame(draw);
  if(!ready || document.hidden || now-lastFrame<1000/30) return;
  const delta=Math.min((now-lastFrame)/1000,.1);
  lastFrame=now;
  if(!paused) motionTime+=delta;
  const wind=!paused && now<windUntil ? Math.sin(Math.max(0,(windUntil-now)/2800)*Math.PI)*20 : 0;
  if(paintedMotion===motionTime && paintedWind===wind) return;
  paintedMotion=motionTime;paintedWind=wind;
  ctx.clearRect(0,0,canvas.width,canvas.height);
  const scale=canvas.height/plant.height;
  const width=plant.width*scale;
  const left=(canvas.width-width)/2;
  for(let sourceY=0;sourceY<plant.height;sourceY+=4) {
    const y=sourceY/plant.height;
    const anchored=Math.pow(Math.max(0,(.65-y)/.65),1.4);
    const sway=(Math.sin(motionTime*1.3+y*2.4)*7+Math.sin(motionTime*2.1+y*7)*1.4+Math.sin(motionTime*6+y*5)*wind)*anchored;
    const rowHeight=Math.min(4,plant.height-sourceY);
    ctx.drawImage(sprite,0,sourceY,plant.width,rowHeight,left+sway,sourceY*scale,width,rowHeight*scale+.4);
  }
}
render();renderMotion();requestAnimationFrame(draw);
