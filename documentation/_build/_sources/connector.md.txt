# Tâche de déplacement du connecteur de la sonde

<style>
    .image{
    border: 5px solid #116aa4;
    border-radius: 10px;
    /* padding: 2px; */
    }
</style>

## Objectifs

- Localiser la task-board avec SIFT (comme toutes les tâches à réaliser),
- Atteindre la position initiale du connecteur de la sonde (`port noir`),
- Pouvoir saisir le connecteur sans endommager le connecteur, ni la boîte, en soignant la trajectoire de montée
- Localiser la position finale du port dans lequel le connecteur est destiné (`port rouge`),
- Trouver la bonne trajectoire pour l'insertion (nécessité d'une grande précision ici pour éviter tout endommagement)
- Insérer le connecteur assez profond pour que la tâche soit valide, et lâcher le connecteur de la sonde

## Etapes principales 

- Ouverture des pinces pour pouvoir saisir le connecteur de la sonde qui est par défaut placé au niveau du port noir,
- Déplacement de l'effecteur finale vers la TF au niveau du port noir `task_board_starting_connector_hole_link`, avec une certaine hauteur,
- Saisie du connecteur,
- Deconnexion du connecteur du port noir (donc déplacement vers le haut du conecteur),
- Déplacement de l'effecteur finale vers la TF au niveau du port rouge `task_board_ending_connector_hole_link`, avec une certaine hauteur,
- Insertion du connecteur dans le port rouge en intégrant une trajectoire en spirale pour permettre d'être sûr d'insérer au bon endroit,
- Retour de l'effecteur finale à une position "`home2`".

Vous pouvez voir ci-dessous le script python ("`connector_hole.py`") permettant de planifier la trajectoire de l'effecteur finale, pour la saisie et le rebranchement du connecteur de la sonde :

```bash
class Connector:
    def __init__(self):
        rospy.init_node('connector_hole', anonymous=True)
        self.rate = rospy.Rate(100)
        self.panda = Panda_R()
        self.panda.set_stiffness(4000, 4000, 4000, 50, 50, 50, 1)
        self._service = rospy.Service('connector_srv', Trigger, self.run)
    
    def run(self, req):
        final_resp = TriggerResponse()

        ####################################################################################
        ############################## Tâche du connecteur #################################

        # Ouverture des pinces de l'effecteur finale
        self.panda.move_gripper(0.05)
        rospy.sleep(1.0)
        # Get character from console
        # Déplacement de la TF `tool` (reliée à l'EE) à la TF du port noir initiale
        self.panda.go_to_frame('task_board_starting_connector_hole_link', 'tool', True, 0.1)
        # Compensation du décalage des TF par rapport aux positions réelles
        self.panda.offset_compensator(10)
        # Modification de la hauteur une fois les TFs aligner
        self.panda.go_to_frame('task_board_starting_connector_hole_link', 'tool', True, 0.002)

        # Fermeture de l'effecteur pour la saisie du connecteur
        self.panda.grasp_gripper(0.0015)
        rospy.sleep(1.0)
        # Changement de hauteur de la TF `tool` pour retirer le connecteur du port noir
        self.panda.go_to_frame('task_board_starting_connector_hole_link', 'tool', True, 0.1)
        # Compensation du décalage des TF par rapport aux positions réelles
        self.panda.offset_compensator(10)
        # Réglage des raideurs selon les axes en position et en orientation, de l'effecteur finale
        self.panda.set_stiffness(2000, 2000, 2000, 50, 50, 50, 1)
        # Déplacement de la TF `tool` vers la TF du port rouge
        self.panda.go_to_frame('task_board_ending_connector_hole_link', 'tool', True, 0.1)
        # Compensation du décalage des TF par rapport aux positions réelles
        self.panda.offset_compensator(10)
        # Réglage des raideurs selon les axes en position et en orientation, de l'effecteur finale
        self.panda.set_stiffness(100, 100, 1000, 50, 50, 50, 1)
        # self.panda.go_to_frame('task_board_ending_connector_hole_link', 'tool', True, 0.03)
        # Changement de hauteur de la TF `tool` pour placer le connecteur au dessus du port rouge
        self.panda.go_to_frame('task_board_ending_connector_hole_link', 'tool', True, 0.023)

        theta = np.linspace(0, 5*2*np.pi, 2000)

        # the radius of the circle
        r = np.linspace(0.003, 0.001, 2000)

        # compute x1 and x2
        x = r*np.cos(theta) + self.panda.curr_pos[0]
        y = r*np.sin(theta) + self.panda.curr_pos[1]
        z = np.linspace(self.panda.curr_pos[2], self.panda.curr_pos[2]-0.025, 2000)

        # Génération d'une trajectoire en spirale pour permettre d'insérer le connecteur avec prudence au niveau du port
        self.panda.play_trajectory(x, y, z)
        # Insertion du connecteur dans le port rouge
        self.panda.go_to_frame('task_board_ending_connector_hole_link', 'tool', True, 0.003)

        # Réglage des raideurs selon les axes en position et en orientation, de l'effecteur finale
        self.panda.set_stiffness(2000, 2000, 2000, 50, 50, 50, 1)
        # Ouverture des grippeurs pour relâcher le connecteur
        self.panda.move_gripper(0.05)
        rospy.sleep(1.0)
        # Mise en position de repos du robot
        self.panda.home(0.25)

        #####################################################################################
        #####################################################################################

        final_resp.message = f"End connector"
        final_resp.success = True
        return final_resp
```

### Vidéo de démonstration de la tâche

On vous met ci-dessous la vidéo de simulation de l'exécution de la tâche du déplacement du connecteur de la sonde du port, sur RVIZ et avec le robot réel, noir au port rouge :

<table align="center" cellspacing="20" cellpadding="5">
    <tr>
        <th>
            <div class="image">
            <iframe width="700" height="600" src="https://drive.google.com/file/d/1zPRZtJ2xx7lAX1rjNHTEf67RcRY1jYd4/preview" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </div>
        </th>
        <th>
            <div class="image">
            <iframe width="700" height="600" src="https://drive.google.com/file/d/1EBnWxSV949HCzNa1_ls4fdOVQBamQciP/preview" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </div>
        </th>
    </tr>
</table>

```{mermaid}
---
caption: Simulation de la tâche du connecteur de la sonde avec les positions initiales home et home2 sur RVIZ, et en réel
align: 'center'
---
graph LR

```

