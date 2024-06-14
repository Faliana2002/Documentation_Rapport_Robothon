# Installation du noyau temps réel

<style>
    .image{
    border: 5px solid #116aa4;
    border-radius: 10px;
    /* padding: 2px; */
    }
</style>

## Description d'un noyau "Temps Réel"

Par définition, le temps réel est une propriété d'un système où les tâches critiques sont garanties d'être exécutées dans un temps prédéterminé. Cela est essentiel pour les applications où la rapidité et la prévisibilité des réponses sont cruciales, comme dans notre cas ici, la robotique, mais aussi les systèmes embarqués, et diverses applications industrielles. 

Il ne faut pas confondre le temps réel avec la vitesse. Un exemple concret : le système de commande d'un avion nécessite un temps de réponse de l'ordre de la microseconde alors qu'un système de contrôle d'une chaîne de production nécessitera un temps de réponse de l'ordre de la milliseconde. En revanche, les deux systèmes devront tous les deux répondre dans un laps de temps défini et ne pas le dépasser : ce qui représente le temps réel. Il existe deux notions distinctes de temps réel : le temps réel dit "*strict*" (`hard real time`) et le temps réel dit "*souple*" (`soft real time`).

Pour pouvoir contrôler le robot Franka Emika en temps réel, il est nécessaire d'avoir un noyau Linux Temps Réel. Le site sur la documentation interface de Franka Emika (<a class="reference external" href="https://frankaemika.github.io/docs/index.html">FCI</a>) nous propose directement les instructions pour l'installation d'un noyau Linux Temps Réel adapté à ROS et au robot sur ce <a class="reference external" href="https://frankaemika.github.io/docs/installation_linux.html#setting-up-the-real-time-kernel">lien</a>.

## Les étapes principales pour l'installation du noyau temps réel
- Installation des dépendances 
- Le téléchargement des sources du Noyau et du Patch Temps Réel :
  - Le Patch Temps Réel ou `PREEMPT_RT`, est une modification apportée au noyau Linux standard pour améliorer ses capacités de traitement en temps réel. Le principe de ce patch est d'autoriser la préemption partput même dans les interruptions, à l'aide de l'ajout de différents mécanismes.
  Voici un <a class="reference external" href="https://www.linuxembedded.fr/2019/09/le-temps-reel-sous-linux">lien</a> permettant de mieux comprendre l'aspect temps réel d'un noyau et comment choisir correctement les options annexes en fonction des performances attendues.
- Décompression des fichiers
- Vérification de l'intégrité des fichiers à l'aide de "*gpg2*" :
  - *gpg2* (ou `GNU Privacy Guard`) est une implémentation libre de la norme OpenPGP(`Prety Good Privacy`). Lors de l'installation d'un noyau temps réel, il est plus que nécessaire de s'assurer que les fichiers téléchargés ne sont pas corrompus ou compromis. L'utilisation de "*gpg2*" permet donc de vérifier l'intégrité et l'authenticité des fichiers sources et des patches.
- Compilation du noyau
- Compilation et installation
- Configuration des Permissions Temps Réel :
  - Ajout d'un groupe *realtime* et configuration des limites pour le groupe en question

Ces étapes permettent donc d'installer et de configurer un noyau Linux Temps Réel pour contrôler un robot en utilisant les librairies `libfranka` et `franka_ros`. Cette configuration assure que le programme de contrôle fonctionne avec une priorité temps réel.


