import librosa
import sys
import warnings

def analyze_tempo(file_path):
    try:
        # Supprimer les avertissements
        warnings.filterwarnings("ignore", category=UserWarning)
        warnings.filterwarnings("ignore", category=FutureWarning)
        
        # Charger l'audio avec librosa
        y, sr = librosa.load(file_path, sr=None)
        
        # Estimer le tempo
        tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
        
        # Convertir le tempo en float pour éviter les erreurs de formatage
        tempo = float(tempo)
        print(f"{tempo:.2f}")
    except Exception as e:
        print(f"Erreur lors de l'analyse du fichier : {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage : python analyze_tempo.py <chemin_du_fichier_mp3>")
    else:
        file_path = sys.argv[1]
        analyze_tempo(file_path)
