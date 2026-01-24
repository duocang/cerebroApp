// layout for 2D projections
const spatial_projection_layout_2D = {
  uirevision: 'true',
  hovermode: 'closest',
  margin: {
    l: 50,
    r: 50,
    b: 50,
    t: 50,
    pad: 4,
  },
  legend: {
    itemsizing: 'constant',
  },
  xaxis: {
    autorange: true,
    mirror: true,
    showline: true,
    zeroline: false,
    range: [],
    gridcolor: '#E2E8F0',
    linecolor: '#CBD5E0',
    tickfont: {
      color: '#718096',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
    titlefont: {
      color: '#2D3748',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
  },
  yaxis: {
    autorange: true,
    mirror: true,
    showline: true,
    zeroline: false,
    range: [],
    gridcolor: '#E2E8F0',
    linecolor: '#CBD5E0',
    tickfont: {
      color: '#718096',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
    titlefont: {
      color: '#2D3748',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
  },
  hoverlabel: {
    font: {
      size: 12,
      color: '#2D3748',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
    bgcolor: 'rgba(255, 255, 255, 0.95)',
    bordercolor: '#E2E8F0',
    align: 'left',
  },
  plot_bgcolor: 'rgba(255, 255, 255, 0)',
  paper_bgcolor: 'rgba(255, 255, 255, 0)',
};

// Inject CSS for counter-rotation of text elements
(function () {
  const style = document.createElement('style');
  style.innerHTML = `
    #spatial_projection {
      --spatial-rotation: 0deg;
    }
    #spatial_projection .textpoint text {
      transform: rotate(var(--spatial-rotation));
      transform-box: fill-box;
      transform-origin: center center;
    }
    #spatial_projection .hoverlayer .hovertext {
      transform: rotate(var(--spatial-rotation));
      transform-box: fill-box;
      transform-origin: center center;
    }

    /* Rotated State Styles */
    #spatial_projection.is-rotated .main-svg {
      background: rgba(0,0,0,0) !important;
    }
    #spatial_projection.is-rotated .bg {
      fill-opacity: 0 !important;
    }
    #spatial_projection.is-rotated .cartesianlayer .xaxislayer-above,
    #spatial_projection.is-rotated .cartesianlayer .yaxislayer-above,
    #spatial_projection.is-rotated .cartesianlayer .gridlayer,
    #spatial_projection.is-rotated .cartesianlayer .zerolinelayer,
    #spatial_projection.is-rotated .infolayer .g-xtitle,
    #spatial_projection.is-rotated .infolayer .g-ytitle {
      display: none !important;
    }
    #spatial_projection.is-rotated .cartesianlayer .plot path,
    #spatial_projection.is-rotated .cartesianlayer .plot rect {
      stroke: none !important;
      fill: none !important;
    }
    #spatial_projection.is-rotated .cartesianlayer .plot {
      border: none !important;
    }
    #spatial_projection.is-rotated .cartesianlayer path,
    #spatial_projection.is-rotated .cartesianlayer rect {
      stroke: none !important;
      fill: none !important;
    }
    #spatial_projection.is-rotated .cartesianlayer .xaxislayer-below path,
    #spatial_projection.is-rotated .cartesianlayer .yaxislayer-below path {
      stroke: none !important;
    }

    /* Custom Legend Styles */
    #spatial_projection_legend {
      position: absolute;
      top: 10px;
      right: 10px;
      background: rgba(255, 255, 255, 0.95);
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      padding: 12px;
      max-height: 300px;
      overflow-y: auto;
      z-index: 1000;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      cursor: move;
    }
    .custom-legend-item {
      display: flex;
      align-items: center;
      margin-bottom: 6px;
      cursor: pointer;
      user-select: none;
      padding: 4px 6px;
      border-radius: 4px;
      transition: background-color 0.2s ease;
    }
    .custom-legend-item:hover {
      background-color: rgba(91, 124, 153, 0.08);
    }
    .custom-legend-item:last-child {
      margin-bottom: 0;
    }
    .legend-color-box {
      width: 16px;
      height: 16px;
      margin-right: 10px;
      border-radius: 4px;
      flex-shrink: 0;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }
    .legend-text {
      font-size: 13px;
      color: #2D3748;
      font-weight: 500;
    }
    .legend-item-hidden .legend-text {
      text-decoration: line-through;
      color: #A0AEC0;
    }
    .legend-item-hidden .legend-color-box {
      opacity: 0.4;
    }

    /* Continuous Legend Styles */
    .continuous-legend {
      position: absolute;
      top: 10px;
      right: 10px;
      background: rgba(255, 255, 255, 0.95);
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      padding: 12px;
      z-index: 1000;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      cursor: move;
      min-width: 80px;
    }
    .continuous-legend-title {
      font-size: 13px;
      color: #2D3748;
      font-weight: 500;
      margin-bottom: 8px;
      text-align: center;
    }
    .continuous-legend-gradient {
      width: 20px;
      height: 150px;
      margin: 0 auto;
      border-radius: 4px;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
    }
    .continuous-legend-labels {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      height: 150px;
      margin-left: 8px;
    }
    .continuous-legend-label {
      font-size: 11px;
      color: #718096;
      font-weight: 400;
    }
    .continuous-legend-content {
      display: flex;
      align-items: center;
    }
    .detached-modebar {
      position: absolute !important;
      top: 0px !important;
      right: 0px !important;
      z-index: 1001 !important;
    }
    .detached-modebar .modebar-btn {
      background: transparent;
      border: none;
      border-radius: 4px;
      box-shadow: none;
      transition: all 0.2s ease;
    }
    .detached-modebar .modebar-btn:hover {
      background: rgba(91, 124, 153, 0.1);
      border: none;
      transform: translateY(-1px);
      box-shadow: none;
    }
    .detached-modebar .modebar-btn svg {
      fill: #5B7C99;
    }
    .detached-modebar .modebar-btn:hover svg {
      fill: #3D5A73;
    }
    .detached-modebar .modebar-group {
      display: flex !important;
      flex-direction: row !important;
      align-items: center !important;
      gap: 4px !important;
    }
    .detached-modebar .modebar {
      display: flex !important;
      flex-direction: row !important;
      align-items: center !important;
      gap: 8px !important;
    }
  `;
  document.head.appendChild(style);
})();

shinyjs.detachModebar = function () {
  const plotContainer = document.getElementById('spatial_projection');
  if (!plotContainer) return;

  const parent = plotContainer.parentElement;
  if (getComputedStyle(parent).position === 'static') {
    parent.style.position = 'relative';
  }

  // Find the modebar inside the plot container
  const modebar = plotContainer.querySelector('.modebar-container') || plotContainer.querySelector('.modebar');

  if (modebar) {
    // Remove stale detached modebars
    const staleModebars = parent.querySelectorAll('.detached-modebar');
    staleModebars.forEach((el) => el.remove());

    parent.appendChild(modebar);
    modebar.classList.add('detached-modebar');
  }
};

// Custom Legend Helper Functions
shinyjs.makeDraggable = function (el) {
  let isDragging = false;
  let hasMoved = false;
  let startX, startY, initialLeft, initialTop;

  el.onmousedown = function (e) {
    // Only left mouse button
    if (e.button !== 0) return;

    isDragging = true;
    hasMoved = false;
    startX = e.clientX;
    startY = e.clientY;

    // Get current position
    const rect = el.getBoundingClientRect();
    const parentRect = el.parentElement.getBoundingClientRect();

    // Convert to relative position (left/top)
    initialLeft = rect.left - parentRect.left;
    initialTop = rect.top - parentRect.top;

    // Switch to left/top positioning if not already
    el.style.right = 'auto';
    el.style.bottom = 'auto';
    el.style.left = initialLeft + 'px';
    el.style.top = initialTop + 'px';

    el.style.cursor = 'grabbing';

    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);

    // Prevent default text selection
    e.preventDefault();
  };

  function onMouseMove(e) {
    if (!isDragging) return;

    const dx = e.clientX - startX;
    const dy = e.clientY - startY;

    if (dx !== 0 || dy !== 0) {
      hasMoved = true;
      el.dataset.isDragging = 'true';
    }

    el.style.left = initialLeft + dx + 'px';
    el.style.top = initialTop + dy + 'px';
  }

  function onMouseUp(e) {
    isDragging = false;
    el.style.cursor = 'move';
    document.removeEventListener('mousemove', onMouseMove);
    document.removeEventListener('mouseup', onMouseUp);

    if (hasMoved) {
      // Keep the flag for a short moment to block click events on children
      setTimeout(() => {
        el.dataset.isDragging = 'false';
      }, 50);
    } else {
      el.dataset.isDragging = 'false';
    }
  }
};

shinyjs.createCustomLegend = function (traces, colors) {
  const plotContainer = document.getElementById('spatial_projection');
  if (!plotContainer) return;

  // Ensure parent has relative positioning
  const parent = plotContainer.parentElement;
  if (getComputedStyle(parent).position === 'static') {
    parent.style.position = 'relative';
  }

  // Find or create legend container
  let legendContainer = document.getElementById('spatial_projection_legend');
  if (!legendContainer) {
    legendContainer = document.createElement('div');
    legendContainer.id = 'spatial_projection_legend';
    parent.appendChild(legendContainer);
  }

  // Enable dragging
  shinyjs.makeDraggable(legendContainer);

  // Reset content
  legendContainer.innerHTML = '';
  legendContainer.style.display = 'block';

  // Create legend items
  traces.forEach((traceName, index) => {
    const item = document.createElement('div');
    item.className = 'custom-legend-item';

    const colorBox = document.createElement('span');
    colorBox.className = 'legend-color-box';
    colorBox.style.backgroundColor = colors[index];

    const text = document.createElement('span');
    text.className = 'legend-text';
    text.innerText = traceName;

    item.appendChild(colorBox);
    item.appendChild(text);

    // Toggle visibility on click
    item.onclick = function () {
      if (legendContainer.dataset.isDragging === 'true') return;

      const plot = document.getElementById('spatial_projection');
      // Check current visibility status (default is visible/true)
      // We assume trace index corresponds to legend index
      let isVisible = true;
      if (plot.data && plot.data[index]) {
        isVisible = plot.data[index].visible !== false && plot.data[index].visible !== 'legendonly';
      }

      const newVisible = isVisible ? false : true;
      Plotly.restyle('spatial_projection', { visible: newVisible }, [index]);

      item.classList.toggle('legend-item-hidden', isVisible);
    };

    legendContainer.appendChild(item);
  });
};

shinyjs.removeCustomLegend = function () {
  const legendContainer = document.getElementById('spatial_projection_legend');
  if (legendContainer) {
    legendContainer.style.display = 'none';
  }
};

shinyjs.createContinuousLegend = function (title, colorMin, colorMax, colorscale) {
  const plotContainer = document.getElementById('spatial_projection');
  if (!plotContainer) return;

  const parent = plotContainer.parentElement;
  if (getComputedStyle(parent).position === 'static') {
    parent.style.position = 'relative';
  }

  let legendContainer = document.getElementById('spatial_projection_continuous_legend');
  if (!legendContainer) {
    legendContainer = document.createElement('div');
    legendContainer.id = 'spatial_projection_continuous_legend';
    parent.appendChild(legendContainer);
  }

  shinyjs.makeDraggable(legendContainer);
  legendContainer.innerHTML = '';
  legendContainer.style.display = 'block';
  legendContainer.className = 'continuous-legend';

  const titleEl = document.createElement('div');
  titleEl.className = 'continuous-legend-title';
  titleEl.innerText = title;
  legendContainer.appendChild(titleEl);

  const contentEl = document.createElement('div');
  contentEl.className = 'continuous-legend-content';

  const gradientEl = document.createElement('div');
  gradientEl.className = 'continuous-legend-gradient';

  const gradientColors = colorscale.map((item) => item[1]).join(', ');
  gradientEl.style.background = `linear-gradient(to top, ${gradientColors})`;

  const labelsEl = document.createElement('div');
  labelsEl.className = 'continuous-legend-labels';

  const minLabel = document.createElement('div');
  minLabel.className = 'continuous-legend-label';
  minLabel.innerText = colorMin.toFixed(2);

  const maxLabel = document.createElement('div');
  maxLabel.className = 'continuous-legend-label';
  maxLabel.innerText = colorMax.toFixed(2);

  labelsEl.appendChild(maxLabel);
  labelsEl.appendChild(minLabel);

  contentEl.appendChild(gradientEl);
  contentEl.appendChild(labelsEl);
  legendContainer.appendChild(contentEl);
};

shinyjs.removeContinuousLegend = function () {
  const legendContainer = document.getElementById('spatial_projection_continuous_legend');
  if (legendContainer) {
    legendContainer.style.display = 'none';
  }
};

// layout for 3D projections
const spatial_projection_layout_3D = {
  uirevision: 'true',
  hovermode: 'closest',
  margin: {
    l: 50,
    r: 50,
    b: 50,
    t: 50,
    pad: 4,
  },
  legend: {
    itemsizing: 'constant',
  },
  scene: {
    xaxis: {
      autorange: true,
      mirror: true,
      showline: true,
      zeroline: false,
      range: [],
      gridcolor: '#E2E8F0',
      linecolor: '#CBD5E0',
      tickfont: {
        color: '#718096',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
      titlefont: {
        color: '#2D3748',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
    },
    yaxis: {
      autorange: true,
      mirror: true,
      showline: true,
      zeroline: false,
      range: [],
      gridcolor: '#E2E8F0',
      linecolor: '#CBD5E0',
      tickfont: {
        color: '#718096',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
      titlefont: {
        color: '#2D3748',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
    },
    zaxis: {
      autorange: true,
      mirror: true,
      showline: true,
      zeroline: false,
      gridcolor: '#E2E8F0',
      linecolor: '#CBD5E0',
      tickfont: {
        color: '#718096',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
      titlefont: {
        color: '#2D3748',
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      },
    },
  },
  hoverlabel: {
    font: {
      size: 12,
      color: '#2D3748',
      family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    },
    bgcolor: 'rgba(255, 255, 255, 0.95)',
    bordercolor: '#E2E8F0',
    align: 'left',
  },
  plot_bgcolor: 'rgba(255, 255, 255, 0)',
  paper_bgcolor: 'rgba(255, 255, 255, 0)',
};

// structure of input data
const spatial_projection_default_params = {
  meta: {
    color_type: '',
    traces: [],
    color_variable: '',
  },
  data: {
    x: [],
    y: [],
    z: [],
    color: [],
    size: '',
    opacity: '',
    line: {},
    x_range: [],
    y_range: [],
    reset_axes: false,
  },
  hover: {
    hoverinfo: '',
    text: [],
  },
  group_centers: {
    group: [],
    x: [],
    y: [],
    z: [],
  },
  container: {
    width: null,
    height: null,
  },
};

// update 2D projection with continuous coloring
shinyjs.updatePlot2DContinuousSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
  shinyjs.removeCustomLegend();
  shinyjs.removeContinuousLegend();
  const data = [];
  const colorArray = params.data.color;
  const colorMin = Math.min(...colorArray);
  const colorMax = Math.max(...colorArray);
  const colorscale = [
    [0, '#E8F4F8'],
    [0.2, '#D1E8ED'],
    [0.4, '#A8D0DC'],
    [0.6, '#7FB8CB'],
    [0.8, '#5B9FB8'],
    [1, '#3D7A9E'],
  ];
  data.push({
    x: params.data.x,
    y: params.data.y,
    mode: 'markers',
    type: 'scattergl',
    marker: {
      size: params.data.point_size,
      opacity: params.data.point_opacity,
      line: params.data.point_line,
      color: params.data.color,
      cmin: colorMin,
      cmax: colorMax,
      colorscale: colorscale,
      showscale: false,
    },
    hoverinfo: params.hover.hoverinfo,
  });
  shinyjs.createContinuousLegend(params.meta.color_variable, colorMin, colorMax, colorscale);
  const layout_here = Object.assign(spatial_projection_layout_2D);
  if (params.data.reset_axes) {
    layout_here.xaxis['autorange'] = true;
    layout_here.yaxis['autorange'] = true;
  } else {
    layout_here.xaxis['autorange'] = false;
    layout_here.xaxis['range'] = params.data.x_range;
    layout_here.yaxis['autorange'] = false;
    layout_here.yaxis['range'] = params.data.y_range;
  }
  if (params.container && params.container.width && params.container.height) {
    layout_here.width = params.container.width;
    layout_here.height = params.container.height;
  } else {
    const plotContainer = document.getElementById('spatial_projection');
    if (plotContainer && plotContainer.parentElement) {
      layout_here.width = plotContainer.parentElement.clientWidth;
      layout_here.height = plotContainer.parentElement.clientHeight;
    }
  }

  // Apply rotation if needed
  const plotContainer = document.getElementById('spatial_projection');
  const angle = plotContainer ? parseFloat(plotContainer.dataset.angle || 0) : 0;

  // Stash original data
  data.forEach((trace) => {
    trace.orig_x = trace.x;
    trace.orig_y = trace.y;
  });

  if (angle !== 0) {
    let cx = 0,
      cy = 0;
    if (layout_here.images && layout_here.images.length > 0) {
      const img = layout_here.images[0];
      cx = img.x + img.sizex / 2;
      cy = img.y - img.sizey / 2;
    }
    const rad = (-angle * Math.PI) / 180;
    const cos = Math.cos(rad);
    const sin = Math.sin(rad);

    data.forEach((trace) => {
      if (Array.isArray(trace.x)) {
        const newX = [];
        const newY = [];
        for (let j = 0; j < trace.x.length; j++) {
          const x = trace.x[j];
          const y = trace.y[j];
          const dx = x - cx;
          const dy = y - cy;
          newX.push(dx * cos - dy * sin + cx);
          newY.push(dx * sin + dy * cos + cy);
        }
        trace.x = newX;
        trace.y = newY;
      }
    });
  }

  Plotly.react('spatial_projection', data, layout_here).then(() => shinyjs.detachModebar());
};

// update 3D projection with continuous coloring
shinyjs.updatePlot3DContinuousSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
  shinyjs.removeCustomLegend();
  shinyjs.removeContinuousLegend();
  const data = [];
  const colorArray = params.data.color;
  const colorMin = Math.min(...colorArray);
  const colorMax = Math.max(...colorArray);
  const colorscale = [
    [0, '#E8F4F8'],
    [0.2, '#D1E8ED'],
    [0.4, '#A8D0DC'],
    [0.6, '#7FB8CB'],
    [0.8, '#5B9FB8'],
    [1, '#3D7A9E'],
  ];
  data.push({
    x: params.data.x,
    y: params.data.y,
    z: params.data.z,
    mode: 'markers',
    type: 'scatter3d',
    marker: {
      size: params.data.point_size,
      opacity: params.data.point_opacity,
      line: params.data.point_line,
      color: params.data.color,
      cmin: colorMin,
      cmax: colorMax,
      colorscale: colorscale,
      reversescale: true,
      showscale: false,
    },
    showlegend: false,
  });
  shinyjs.createContinuousLegend(params.meta.color_variable, colorMin, colorMax, colorscale);
  const layout_here = Object.assign(spatial_projection_layout_3D);
  if (params.container && params.container.width && params.container.height) {
    layout_here.width = params.container.width;
    layout_here.height = params.container.height;
  } else {
    const plotContainer = document.getElementById('spatial_projection');
    if (plotContainer && plotContainer.parentElement) {
      layout_here.width = plotContainer.parentElement.clientWidth;
      layout_here.height = plotContainer.parentElement.clientHeight;
    }
  }

  // Apply rotation if needed
  const plotContainer = document.getElementById('spatial_projection');
  const angle = plotContainer ? parseFloat(plotContainer.dataset.angle || 0) : 0;

  // Stash original data
  data.forEach((trace) => {
    trace.orig_x = trace.x;
    trace.orig_y = trace.y;
  });

  if (angle !== 0) {
    let cx = 0,
      cy = 0;
    if (layout_here.images && layout_here.images.length > 0) {
      const img = layout_here.images[0];
      cx = img.x + img.sizex / 2;
      cy = img.y - img.sizey / 2;
    }
    const rad = (-angle * Math.PI) / 180;
    const cos = Math.cos(rad);
    const sin = Math.sin(rad);

    data.forEach((trace) => {
      if (Array.isArray(trace.x)) {
        const newX = [];
        const newY = [];
        for (let j = 0; j < trace.x.length; j++) {
          const x = trace.x[j];
          const y = trace.y[j];
          const dx = x - cx;
          const dy = y - cy;
          newX.push(dx * cos - dy * sin + cx);
          newY.push(dx * sin + dy * cos + cy);
        }
        trace.x = newX;
        trace.y = newY;
      }
    });
  }

  Plotly.react('spatial_projection', data, layout_here).then(() => shinyjs.detachModebar());
};

shinyjs.applySpatialRotation = function (plotContainer, angle, layout) {
  if (!plotContainer || !plotContainer.data) return;

  // Check if 2D
  const is2D = plotContainer.data.length > 0 && (plotContainer.data[0].type === 'scattergl' || plotContainer.data[0].type === 'scatter');

  if (!is2D) return;

  // Calculate center from layout images
  let cx = 0,
    cy = 0;
  if (layout && layout.images && layout.images.length > 0) {
    const img = layout.images[0];
    // Assuming xref='x', yref='y'
    // x is left, y is top
    cx = img.x + img.sizex / 2;
    cy = img.y - img.sizey / 2;
  }

  // Convert to radians (CW rotation requires negative angle in Cartesian)
  const rad = (-angle * Math.PI) / 180;
  const cos = Math.cos(rad);
  const sin = Math.sin(rad);

  const update = {
    x: [],
    y: [],
  };
  const indices = [];

  for (let i = 0; i < plotContainer.data.length; i++) {
    const trace = plotContainer.data[i];
    // Skip if not scatter/scattergl (e.g. annotations?)
    // Labels trace is 'scatter' mode 'text'. Should rotate too.

    // Ensure we have original coordinates
    let ox = trace.orig_x;
    let oy = trace.orig_y;

    if (!ox || !oy) {
      // If missing, stash current.
      // Note: This assumes current is "0 deg".
      trace.orig_x = trace.x;
      trace.orig_y = trace.y;
      ox = trace.x;
      oy = trace.y;
    }

    // Compute new coordinates
    if (Array.isArray(ox)) {
      const newX = [];
      const newY = [];
      for (let j = 0; j < ox.length; j++) {
        const x = ox[j];
        const y = oy[j];
        // Rotate around (cx, cy)
        const dx = x - cx;
        const dy = y - cy;
        newX.push(dx * cos - dy * sin + cx);
        newY.push(dx * sin + dy * cos + cy);
      }
      update.x.push(newX);
      update.y.push(newY);
      indices.push(i);
    }
  }

  if (indices.length > 0) {
    Plotly.restyle(plotContainer, update, indices);
  }
};

shinyjs.rotateSpatialProjection = function (angle) {
  const plotContainer = document.getElementById('spatial_projection');
  if (plotContainer) {
    const parentContainer = plotContainer.parentElement;
    const isRotated = angle % 360 !== 0;

    // Store angle for future updates
    plotContainer.dataset.angle = angle;

    if (isRotated) {
      plotContainer.classList.add('is-rotated');
      parentContainer.style.overflow = 'visible';
    } else {
      plotContainer.classList.remove('is-rotated');
      parentContainer.style.overflow = ''; // Revert to default
    }

    // Apply data rotation instead of CSS rotation
    // We need the layout to find the center
    const layout = plotContainer.layout;
    shinyjs.applySpatialRotation(plotContainer, angle, layout);

    // Remove CSS rotation if present (from previous version)
    plotContainer.style.transform = '';
    plotContainer.style.removeProperty('--spatial-rotation');
  }
  shinyjs.detachModebar();
};

shinyjs.getContainerDimensions = function () {
  const plotContainer = document.getElementById('spatial_projection');
  if (plotContainer) {
    const parentContainer = plotContainer.parentElement;
    return {
      width: parentContainer.clientWidth,
      height: parentContainer.clientHeight,
    };
  }
  return { width: 0, height: 0 };
};

// update 2D projection with categorical coloring
shinyjs.updatePlot2DCategoricalSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
  shinyjs.removeContinuousLegend();
  shinyjs.createCustomLegend(params.meta.traces, params.data.color);
  const data = [];
  for (let i = 0; i < params.data.x.length; i++) {
    data.push({
      x: params.data.x[i],
      y: params.data.y[i],
      name: params.meta.traces[i],
      mode: 'markers',
      type: 'scattergl',
      marker: {
        size: params.data.point_size,
        opacity: params.data.point_opacity,
        line: params.data.point_line,
        color: params.data.color[i],
      },
      hoverinfo: params.hover.hoverinfo,
      text: params.hover.text[i],
      hoverlabel: {
        bgcolor: 'rgba(255, 255, 255, 0.95)',
        bordercolor: '#E2E8F0',
        font: {
          color: '#2D3748',
          size: 12,
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
        },
      },
      showlegend: false,
    });
  }
  if (params.group_centers.group.length >= 1) {
    data.push({
      x: params.group_centers.x,
      y: params.group_centers.y,
      text: params.group_centers.group,
      type: 'scatter',
      mode: 'text',
      name: 'Labels',
      textposition: 'middle center',
      textfont: {
        color: '#000000',
        size: 16,
      },
      hoverinfo: 'skip',
      inherit: false,
      showlegend: false,
    });
  }
  const layout_here = JSON.parse(JSON.stringify(spatial_projection_layout_2D));

  if (params.meta.background_image && params.meta.image_bounds) {
    layout_here.images = [
      {
        source: params.meta.background_image,
        xref: 'x',
        yref: 'y',
        x: params.meta.image_bounds.xmin,
        y: params.meta.image_bounds.ymax,
        sizex: params.meta.image_bounds.xmax - params.meta.image_bounds.xmin,
        sizey: params.meta.image_bounds.ymax - params.meta.image_bounds.ymin,
        sizing: 'stretch',
        opacity: 1,
        layer: 'below',
      },
    ];
  } else {
    layout_here.images = [];
  }

  if (params.data.reset_axes) {
    layout_here.xaxis.autorange = true;
    delete layout_here.xaxis.range;
    layout_here.yaxis.autorange = true;
    delete layout_here.yaxis.range;
  } else {
    layout_here.xaxis.autorange = false;
    layout_here.xaxis.range = [...params.data.x_range];
    layout_here.yaxis.autorange = false;
    layout_here.yaxis.range = [...params.data.y_range];
  }
  if (params.container && params.container.width && params.container.height) {
    layout_here.width = params.container.width;
    layout_here.height = params.container.height;
  } else {
    const plotContainer = document.getElementById('spatial_projection');
    if (plotContainer && plotContainer.parentElement) {
      layout_here.width = plotContainer.parentElement.clientWidth;
      layout_here.height = plotContainer.parentElement.clientHeight;
    }
  }
  Plotly.react('spatial_projection', data, layout_here).then(() => shinyjs.detachModebar());
};

// update 3D projection with categorical coloring
shinyjs.updatePlot3DCategoricalSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
  shinyjs.removeContinuousLegend();
  shinyjs.createCustomLegend(params.meta.traces, params.data.color);
  const data = [];
  for (let i = 0; i < params.data.x.length; i++) {
    data.push({
      x: params.data.x[i],
      y: params.data.y[i],
      z: params.data.z[i],
      name: params.meta.traces[i],
      mode: 'markers',
      type: 'scatter3d',
      marker: {
        size: params.data.point_size,
        opacity: params.data.point_opacity,
        line: params.data.point_line,
        color: params.data.color[i],
      },
      hoverinfo: params.hover.hoverinfo,
      text: params.hover.text[i],
      hoverlabel: {
        bgcolor: 'rgba(255, 255, 255, 0.95)',
        bordercolor: '#E2E8F0',
        font: {
          color: '#2D3748',
          size: 12,
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
        },
      },
      showlegend: false,
    });
  }
  if (params.group_centers.group.length >= 1) {
    data.push({
      x: params.group_centers.x,
      y: params.group_centers.y,
      z: params.group_centers.z,
      text: params.group_centers.group,
      type: 'scatter3d',
      mode: 'text',
      name: 'Labels',
      textposition: 'middle center',
      textfont: {
        color: '#000000',
        size: 16,
      },
      hoverinfo: 'skip',
      inherit: false,
      showlegend: false,
    });
  }
  const layout_here = JSON.parse(JSON.stringify(spatial_projection_layout_3D));
  if (params.container && params.container.width && params.container.height) {
    layout_here.width = params.container.width;
    layout_here.height = params.container.height;
  } else {
    const plotContainer = document.getElementById('spatial_projection');
    if (plotContainer && plotContainer.parentElement) {
      layout_here.width = plotContainer.parentElement.clientWidth;
      layout_here.height = plotContainer.parentElement.clientHeight;
    }
  }
  Plotly.react('spatial_projection', data, layout_here).then(() => shinyjs.detachModebar());
};
