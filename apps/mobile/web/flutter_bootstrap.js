{{flutter_js}}
{{flutter_build_config}}

// Keep the renderer local so the app works on an intranet and without access
// to Google's CanvasKit CDN.
_flutter.loader.load({
  config: {
    renderer: 'canvaskit',
    canvasKitBaseUrl: 'canvaskit',
  },
});
