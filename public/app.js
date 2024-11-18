let dui = null;

const handlers = {
    show_dui: (data) => {
        if (dui) {
            dui.close();
        }
        dui = new Interaction(data.options);
    },
    close_dui: () => {
        if (dui) {
            dui.close();
        }
    }
};

window.addEventListener('message', function (event) {
    const data = event.data;
    const handler = handlers[data.action];
    if (handler) {
        handler(data);
    }
});
