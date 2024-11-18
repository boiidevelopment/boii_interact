class Interaction {
    constructor(options) {
        this.options = options;
        this.build();
    }

    build() {
        const key_hints = this.options.keys.map(key_obj => {
            return `<div class="interaction_key"><span class="key"><p>${key_obj.key}</p></span> <span class="key_label">${key_obj.label}</span></div>`;
        }).join('');
        const custom_icon = this.options.icon ? `<i class="${this.options.icon}"></i>` : '';
        const content = `
            <div class="interact_ui">
                <div class="interact_header">
                    <span class="header_content">${custom_icon} ${this.options.header || 'Header Missing'}</span>
                </div>
                <div class="keys_container">
                    ${key_hints}
                </div>
            </div>
        `;
        $('#main_container').html(content);
    }

    close() {
        $('#main_container').empty();
    }
}


const test_options = {
    header: 'Testing',
    icon: 'fa-solid fa-gear',
    keys: [
        { key: 'E', label: 'Interact' },
        { key: 'T', label: 'Help' }
    ]
};

//const test_interaction = new Interaction(test_options);