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
  },
  yaxis: {
    autorange: true,
    mirror: true,
    showline: true,
    zeroline: false,
    range: [],
  },
  hoverlabel: {
    font: {
      size: 11,
    },
    align: 'left',
  },
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

     /* Custom Legend Styles */
     #spatial_projection_legend {
        position: absolute;
        top: 10px;
        right: 10px;
        background: rgba(255, 255, 255, 0.9);
        border: 1px solid #ccc;
        border-radius: 4px;
        padding: 8px;
        max-height: 300px;
        overflow-y: auto;
        z-index: 1000;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        font-family: "Open Sans", verdana, arial, sans-serif;
        cursor: move;
      }
      .custom-legend-item {
       display: flex;
       align-items: center;
       margin-bottom: 4px;
       cursor: pointer;
       user-select: none;
     }
     .custom-legend-item:last-child {
       margin-bottom: 0;
     }
     .legend-color-box {
       width: 14px;
       height: 14px;
       margin-right: 8px;
       border-radius: 3px;
       flex-shrink: 0;
     }
     .legend-text {
       font-size: 12px;
       color: #2a3f5f;
     }
     .legend-item-hidden .legend-text {
       text-decoration: line-through;
       color: #aaa;
     }
     .legend-item-hidden .legend-color-box {
       opacity: 0.5;
     }
   `;
  document.head.appendChild(style);
})();

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
    },
    yaxis: {
      autorange: true,
      mirror: true,
      showline: true,
      zeroline: false,
      range: [],
    },
    zaxis: {
      autorange: true,
      mirror: true,
      showline: true,
      zeroline: false,
    },
  },
  hoverlabel: {
    font: {
      size: 11,
    },
    align: 'left',
  },
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
  const data = [];
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
      colorscale: 'YlGnBu',
      reversescale: true,
      colorbar: {
        title: {
          text: params.meta.color_variable,
        },
      },
    },
    hoverinfo: params.hover.hoverinfo,
    text: params.hover.text,
    showlegend: false,
  });
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
  Plotly.react('spatial_projection', data, layout_here);
};

// update 3D projection with continuous coloring
shinyjs.updatePlot3DContinuousSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
  shinyjs.removeCustomLegend();
  const data = [];
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
      colorscale: 'YlGnBu',
      reversescale: true,
      colorbar: {
        title: {
          text: params.meta.color_variable,
        },
      },
    },
    hoverinfo: params.hover.hoverinfo,
    text: params.hover.text,
    showlegend: false,
  });
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
  Plotly.react('spatial_projection', data, layout_here);
};

shinyjs.rotateSpatialProjection = function (angle) {
  const plotContainer = document.getElementById('spatial_projection');
  if (plotContainer) {
    const parentContainer = plotContainer.parentElement;
    const isRotated = angle % 360 !== 0;

    if (isRotated) {
      plotContainer.classList.add('is-rotated');
      parentContainer.style.overflow = 'visible';
    } else {
      plotContainer.classList.remove('is-rotated');
      parentContainer.style.overflow = ''; // Revert to default
    }

    // Set CSS variable for text counter-rotation
    plotContainer.style.setProperty('--spatial-rotation', -angle + 'deg');

    plotContainer.style.transform = `rotate(${angle}deg)`;
    plotContainer.style.transition = 'transform 0.3s ease';
    plotContainer.style.transformOrigin = 'center center';
  }
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
        bgcolor: params.data.color[i],
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
    });
  }
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
  Plotly.react('spatial_projection', data, layout_here);
};

// update 3D projection with categorical coloring
shinyjs.updatePlot3DCategoricalSpatial = function (params) {
  params = shinyjs.getParams(params, spatial_projection_default_params);
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
        bgcolor: params.data.color[i],
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
    });
  }
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
  Plotly.react('spatial_projection', data, layout_here);
};
