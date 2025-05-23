const WebSocket = require('ws');
const express = require('express');
const fs = require('fs');
const { spawn } = require('child_process');

const app = express();
const port = 3001;

// Servir la page HTML sur http://localhost:3001
app.use(express.static(__dirname));
app.listen(port, () => console.log(`📡 Serveur HTTP lancé sur http://localhost:${port}`));

// WebSocket Server sur ws://localhost:3000
const wss = new WebSocket.Server({ port: 3000 });
console.log(`✅ Serveur WebSocket démarré sur ws://localhost:3000`);

let dmxData = new Array(512).fill(0); // Initialisation du tableau DMX

wss.on('connection', ws => {
    console.log("💻 Client connecté");

    // Envoyer l'état actuel des canaux DMX au nouveau client
    ws.send(JSON.stringify({ channels: dmxData }));

    ws.on('message', message => {
        //console.log("📥 Message reçu du client :", message); // DEBUG: Voir le message brut du client

        try {
            const receivedDMX = JSON.parse(message);
            // console.log("✅ Données parsées :", receivedDMX); // DEBUG: Voir les données après parsing

            if (receivedDMX.channels) {
                let hasChanges = false;
                const changes = {}; // Stocke uniquement les canaux modifiés

                // Appliquer uniquement les changements reçus
                for (const [channel, value] of Object.entries(receivedDMX.channels)) {
                    const channelIndex = parseInt(channel, 10);
                    if (channelIndex >= 0 && channelIndex < 512 && dmxData[channelIndex] !== value) {
                        console.log(`🔄 Mise à jour du canal ${channelIndex} : ${dmxData[channelIndex]} ➝ ${value}`);
                        dmxData[channelIndex] = value;
                        changes[channelIndex] = value;
                        hasChanges = true;
                    }
                }

                // Diffuser uniquement les canaux modifiés
                if (hasChanges) {
                    wss.clients.forEach(client => {
                        if (client.readyState === WebSocket.OPEN) {
                            client.send(JSON.stringify({ changes }));
                        }
                    });
                    console.log("📤 Mise à jour DMX envoyée aux clients :", changes);
                } else {
                    console.log("⚠️ Aucun changement détecté, rien n'est envoyé.");
                }
            } else if (receivedDMX.file) {
                // Ensure the uploads directory exists
                const uploadsDir = './uploads';
                if (!fs.existsSync(uploadsDir)) {
                    fs.mkdirSync(uploadsDir);
                }

                // Handle file upload
                const filePath = `${uploadsDir}/${Date.now()}.mp3`;
                fs.writeFileSync(filePath, Buffer.from(receivedDMX.file, 'base64'));
                console.log(`📥 Fichier reçu et enregistré : ${filePath}`);

                // Analyze the file using librosa
                const pythonProcess = spawn('python', ['analyze_tempo.py', filePath]);

                pythonProcess.stdout.on('data', (data) => {
                    const tempo = data.toString().trim();
                    console.log(`🎵 Tempo analysé : ${tempo} BPM`);
                    ws.send(JSON.stringify({ tempo }));
                });

                pythonProcess.stderr.on('data', (data) => {
                    console.error(`❌ Erreur lors de l'analyse : ${data}`);
                });
            }
        } catch (error) {
            console.error("❌ Erreur de parsing du message DMX :", error);
        }
    });

    ws.on('close', () => console.log("❌ Client déconnecté"));
});
