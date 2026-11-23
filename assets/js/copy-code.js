document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('pre').forEach(pre => {
    if (pre.dataset.copyBtn) return;
    pre.dataset.copyBtn = '1';
    pre.style.position = 'relative';
    const btn = document.createElement('button');
    btn.textContent = 'Copy';
    btn.style.cssText = 'position:absolute;top:4px;right:4px;padding:2px 8px;font-size:12px;cursor:pointer;opacity:.7';
    btn.onclick = () => {
      const code = pre.querySelector('code') || pre;
      navigator.clipboard.writeText(code.innerText).then(() => {
        btn.textContent = 'Copied';
        setTimeout(() => (btn.textContent = 'Copy'), 1500);
      });
    };
    pre.appendChild(btn);
  });
});