phpToro.dialog = {
    alert: function(options) {
        return phpToro.nativeCall('dialog', 'alert', options || {});
    },
    confirm: function(options) {
        return phpToro.nativeCall('dialog', 'confirm', options || {});
    },
    prompt: function(options) {
        return phpToro.nativeCall('dialog', 'prompt', options || {});
    },
    actionSheet: function(options) {
        return phpToro.nativeCall('dialog', 'actionSheet', options || {});
    }
};
