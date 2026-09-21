/**
 * MAIN.JS - Global Application Bootstrap & Dynamic DOM Populator
 */

document.addEventListener('DOMContentLoaded', () => {
  // Update copyright year
  const yearElement = document.getElementById('currentYear');
  if (yearElement) {
    yearElement.textContent = new Date().getFullYear().toString();
  }

  // Populate dynamic Game Levels if container exists
  const levelsGrid = document.getElementById('levelsGridContainer');
  if (levelsGrid && typeof GAME_DATA !== 'undefined' && GAME_DATA.levels) {
    levelsGrid.innerHTML = GAME_DATA.levels.map((lvl, index) => `
      <div class="glass-card reveal delay-${(index % 4) + 1}">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <span class="badge" style="background: ${lvl.color}22; color: ${lvl.color}; border-color: ${lvl.color}44;">${lvl.badge}</span>
          <span style="font-size: 0.85rem; font-weight: 700; color: var(--text-muted);">${lvl.element} Realm</span>
        </div>
        <h3 style="font-size: 1.5rem; color: #ffffff; margin-bottom: 0.5rem;">${lvl.name} Biome</h3>
        <p style="font-size: 0.95rem; color: var(--text-muted); margin-bottom: 1.25rem;">${lvl.description}</p>
        <div style="padding-top: 0.75rem; border-top: 1px solid var(--border-glass); display: flex; justify-content: space-between; font-size: 0.85rem;">
          <span><strong>Difficulty:</strong> ${lvl.difficulty}</span>
          <span style="color: var(--accent-red);"><strong>Boss:</strong> ${lvl.boss}</span>
        </div>
      </div>
    `).join('');
  }

  // Populate dynamic Features grid if container exists
  const featuresGrid = document.getElementById('featuresGridContainer');
  if (featuresGrid && typeof GAME_DATA !== 'undefined' && GAME_DATA.features) {
    featuresGrid.innerHTML = GAME_DATA.features.map((feat, index) => `
      <div class="glass-card reveal delay-${(index % 3) + 1}">
        <div style="font-size: 2.5rem; margin-bottom: 1rem;">${feat.icon}</div>
        <span class="badge" style="margin-bottom: 0.75rem;">${feat.tag}</span>
        <h3 style="font-size: 1.4rem; color: #ffffff; margin-bottom: 0.5rem;">${feat.title}</h3>
        <p style="font-size: 0.95rem; color: var(--text-muted); margin: 0;">${feat.description}</p>
      </div>
    `).join('');
  }

  // Populate dynamic Weapons grid if container exists
  const weaponsGrid = document.getElementById('weaponsGridContainer');
  if (weaponsGrid && typeof GAME_DATA !== 'undefined' && GAME_DATA.weapons) {
    weaponsGrid.innerHTML = GAME_DATA.weapons.map((wep, index) => `
      <div class="glass-card reveal delay-${(index % 4) + 1}">
        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1rem;">
          <div style="font-size: 2.5rem;">${wep.icon}</div>
          <div>
            <h3 style="font-size: 1.3rem; margin: 0; color: #ffffff;">${wep.name}</h3>
            <span class="badge" style="font-size: 0.7rem;">${wep.type}</span>
          </div>
        </div>
        <p style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1rem;">${wep.desc}</p>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 0.5rem; text-align: center; background: rgba(0,0,0,0.3); padding: 0.6rem; border-radius: var(--radius-sm); font-size: 0.8rem;">
          <div><span style="color: var(--text-muted); display: block;">Damage</span><strong>${wep.damage}</strong></div>
          <div><span style="color: var(--text-muted); display: block;">Fire Rate</span><strong>${wep.rate}</strong></div>
          <div><span style="color: var(--text-muted); display: block;">Range</span><strong>${wep.range}</strong></div>
        </div>
      </div>
    `).join('');
  }

  // Populate dynamic Zombie Waves Table if container exists
  const zombieTableBody = document.getElementById('zombieWaveTableBody');
  if (zombieTableBody && typeof GAME_DATA !== 'undefined' && GAME_DATA.zombieMode) {
    zombieTableBody.innerHTML = GAME_DATA.zombieMode.waveRules.map(wave => `
      <tr style="border-bottom: 1px solid var(--border-glass);">
        <td style="padding: 1rem; font-weight: 700; color: var(--accent-red);">Wave ${wave.wave}</td>
        <td style="padding: 1rem; font-weight: 700; color: #ffffff;">${wave.count} Zombie Horde</td>
        <td style="padding: 1rem; color: var(--text-sub);">${wave.title}</td>
        <td style="padding: 1rem; color: var(--text-muted);">${wave.speed}</td>
        <td style="padding: 1rem; color: var(--accent-gold);">${wave.hp}</td>
      </tr>
    `).join('');
  }

  // Populate Controls Table if container exists
  const controlsTableBody = document.getElementById('controlsTableBody');
  if (controlsTableBody && typeof GAME_DATA !== 'undefined' && GAME_DATA.controls) {
    controlsTableBody.innerHTML = GAME_DATA.controls.map(ctrl => `
      <tr style="border-bottom: 1px solid var(--border-glass);">
        <td style="padding: 1rem;">
          <kbd style="background: rgba(99, 102, 241, 0.2); border: 1px solid var(--border-active); color: #ffffff; padding: 0.3rem 0.75rem; border-radius: 4px; font-family: monospace; font-weight: bold;">${ctrl.key}</kbd>
        </td>
        <td style="padding: 1rem; color: var(--text-sub);">${ctrl.action}</td>
      </tr>
    `).join('');
  }
});
