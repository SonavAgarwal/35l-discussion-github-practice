(() => {
    const grid = document.querySelector(".grid");
    if (!grid) {
        return;
    }

    const buildCard = ({ name, image, link }) => {
        const card = document.createElement("div");
        card.className = "card";

        const seed =
            name && typeof name === "string"
                ? encodeURIComponent(name.trim().toLowerCase().replace(/\s+/g, "-"))
                : "attendee";
        const resolvedImage =
            image && !image.includes("picsum.photos/400?random")
                ? image
                : `https://picsum.photos/seed/${seed}/400`;

        const avatar = document.createElement("div");
        avatar.className = "avatar";

        const img = document.createElement("img");
        img.width = 100;
        img.height = 100;
        img.style.objectFit = "cover";
        img.src = resolvedImage;
        img.alt = name ? `${name} avatar` : "Attendee avatar";

        avatar.appendChild(img);

        const nameWrap = document.createElement("div");
        nameWrap.className = "name";

        const anchor = document.createElement("a");
        anchor.href = link || "#";
        anchor.textContent = name || "Anonymous";

        nameWrap.appendChild(anchor);

        card.appendChild(avatar);
        card.appendChild(nameWrap);

        return card;
    };

    const appendCards = (entries) => {
        entries.forEach((entry) => {
            if (!entry || !entry.name) {
                return;
            }
            grid.appendChild(buildCard(entry));
        });
    };

    const data = Array.isArray(window.attendeeData) ? window.attendeeData : [];
    appendCards(data);
})();
