# Tâche pour le bouton bleu

<section id="tache-pour-appuyer-sur-le-bouton-bleu">
<style>
  .image{
  border: 5px solid #116aa4;
  border-radius: 10px;
  /* padding: 2px; */
  }
</style>

## Objectifs
<ul class="simple">
<div class="blue_button" align="justify">
<li><p>Localiser la task-board avec SIFT (se basant sur la comparaison entre une image de la task-board et le flux capturé par la caméra)</p></li>
<li><p>En simulation, aligner le repère de la task-board virtuelle (“task_board_base_link” défini dans l’URDF de la boîte) avec le repère “box” qui est créé par le SIFT, indiquant la position réelle de la task-board par rapport à la caméra et au robot dans la vie réel</p></li>
<li><p>Aligner le repère du bouton bleu (“task_board_blue_button_link”) et celui de l’effecteur final (“panda_EE”), avant d’appuyer sur le bouton en question</p></li>
<li><p>Exercer une pression sur le bouton bleu de sorte à éviter de l’endommager avec la task-board et revenir en une position de base qu’on a appelé “home” ou “home2” c’est-à-dire une position où l’effecteur est localisé à l’origine avec une hauteur soit de 0.25m soit de 0.5m</p></li>
</div>
</ul>

## Etapes principales pour la réalisation de la tâche
<ul class="simple">
<li><p>Positionner l’effecteur final au-dessus du bouton bleu,</p></li>
<li><p>Ajuster la raideur du bras de robot Panda</p></li>
<li><p>Descendre l’effecteur final jusqu’à au maximum 1mm de profondeur après contact avec le bouton bleu</p></li>
</ul>

## Positionnement de l’effecteur final au niveau du bouton bleu
### Utilisation de ROS
<div class="highlight-bash notranslate"><div class="highlight"><pre><span></span>$<span class="w"> </span>roslaunch<span class="w"> </span>trajectory<span class="w"> </span>franka_positions.launch
</pre></div>
</div>
<ul class="simple">
<li><p><h4>Les différents noeuds lancés par le <code class="docutils literal notranslate"><span class="pre">launchfile</span></code> :</h4></p><br>
<ul>
<li><p>Noeud lancé à partir d’un script “<em>positions.py</em>”, contenant les méthodes pour atteindre les positions de base (“home” et “home2”) et les positions du bouton bleu, du slider et de la trappe,</p></li>
<li><p>Noeud lancé à partir d’un script “<em>trappes.py</em>”, pour l’ouverture de la trappe selon une trajectoire circulaire.</p></li><br>
</ul>
</li>

<li><p><h4>Affichage du repère ou de la TF de l’effecteur final (“<i>panda_EE</i>”) et du bouton bleu (“<i>task_board_blue_button</i>”) :</h4></p></li>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/TF_Task_Blue.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: TFs de l’effecteur final et du bouton bleu.
align: 'center'
---
graph LR

```
<li><p><h4>Alignement des deux TFs :</h4></p></li>
<table align="center">
  <tr>
    <th>
      <div class="image">
        <img src="./img/new/Task_blue.png"/>
      </div>
    </th>
  </tr>
</table>

```{mermaid}
---
caption: TF de l'effecteur placé au-dessus de la TF du bouton bleu.
align: 'center'
---
graph LR

```
### Méthode "*run*" de la classe "*position*" permettant de déplacer l'effecteur final en fonction des saisies dans le terminal

```bash
def run(self):
  while not rospy.is_shutdown():
    position = input("Position : ")
    if position in self.keys.keys():
      char=self.keys[position]
      if char == 'home2':
        self.panda.home(0.25)
      elif char == 'home':
        self.panda.home(0.5)
        self.localization()
      elif char == "quit":  # STOP
        rospy.signal_shutdown("User initiated shutdown")
      elif char == 'test':
        # pose=self.panda.get_pose_EE()
        # rospy.loginfo(pose)
        pose = PoseStamped ()
        pose.pose.position.x = 0
        pose.pose.position.y = 0.2
        pose.pose.position.x = 0

        rospy.loginfo(pose)
        self.panda.go_to_pose_EE('panda_EE',pose,False)
      elif char =='circle':
        # theta goes from 0 to 2pi
        theta = np.linspace(0, 2*np.pi, 2000)

        # the radius of the circle
        r = 0.1

        # compute x1 and x2
        x = r*np.cos(theta) + self.panda.curr_pos[0]
        y = r*np.sin(theta) + self.panda.curr_pos[1]
        # z = np.linspace(self.panda.curr_pos, self.panda.curr_pos, 100)
        z = np.full((2000), self.panda.curr_pos[2])
        self.panda.set_stiffness(4000, 4000, 4000, 50, 50, 50, 10)

        self.panda.play_trajectory(x, y, z)
      elif char == 'door':
        self.door()
      elif char == 'connector':
        self.connector()
      elif char == 'wire':
        self.wire()
      
      ##########################################################################
      ####################### Tâche du bouton bleu #############################
      elif char == 'blue_button':
        self.panda.move_gripper(0.0001)
        self.panda.go_to_frame('task_board_blue_button_link', 'tool', False, 0.1)
        self.panda.go_to_frame('task_board_blue_button_link', 'tool', False)
      ##########################################################################
      ##########################################################################

      else:
        self.panda.go_to_frame(char[0], 'tool', char[1], 0.1)
        self.panda.offset_compensator(10)
        self.panda.go_to_frame(char[0], 'tool', char[1])
              
      self.rate.sleep()
```

Dans cette méthode `run` du script "*positions.py*", on peut déplacer le robot en fonction de toutes les tâches, à partir des TFs définies au niveau de la task-board (définies physiquement dans son **URDF**). Elle contient une condition permettant au bras de robot Panda d'aller appuyer sur le bouton bleu lorsqu'on saisit `blue_button` dans le terminal. La réalisation de la tâche en question suit ces étapes suivantes :
- Fermeture des pinces au niveau de l'effecteur final (avec la méthode "`move_gripper()`" qui permet de contrôler la distance d'ouverture des pinces en fonction d'un argument qui s'exprime en mètre),
- Ensuite la TF "`tool`" va se positionner au niveau de la TF du bouton bleu (`task_board_blue_button`), avec une hauteur de 0.1m,
- Et une fois les deux TFS `tool` et `task_board_blue_button` alignées, l'effecteur finale va descendre appuyer au niveau du bouton, en sachant qu'une elasticité a été définie au niveau de l'effecteur finale pour qu'il évite d'endommager la boîte ou le bouton en appuyant trop fort dessus (donc ici on a un contrôle en position mais aussi en impédance).

## Problèmes rencontrées
<ul class="simple">

<div class="blue_button" align="justify">
<li><p>Stabilisation de SIFT lors de la localisation de la task-board pour avoir une localisation stable au niveau de RVIZ et donc une task-board immobile lorsque la caméra ou le bras de robot n’est pas en mouvement,</p></li>

<li><p>Un décalage a été perçu entre la simulation sur RVIZ et dans la vraie vie car au moment où le bras de robot aller au-dessus du bouton bleu, dans la simulation, le robot était bien au-dessus du bouton bleu, mais avec un décalage dans la vraie vie. Décalage dû à la calibration de la caméra qui est nécessaire, mais aussi au décalage généré par l’écart entre la TF "<code class="docutils literal notranslate"><span class="pre">box</span></code>" et "<code class="docutils literal notranslate"><span class="pre">task_board_base_link</span></code>",</p></li>
<li><p>Le contrôle en impédance a été un sujet soulevé pour éviter d’endommager la task-board et pour que l’effecteur finale puisse appuyer suffisamment fort sans dépasser l’effort supporté par le bouton pour que la tâche soit valide.</p></li>

</div>
</ul>

## Solutions expérimentées
<ul class="simple">
<div class="blue_button" align="justify">
<li><p>Remplacement de l’image de référence pour la localisation avec SIFT, ce qui nous a permis de stabiliser SIFT au niveau de la visualisation de la task-board sur RVIZ,</p></li>
<li><p>Calibration de la caméra à l’aide d'un nuage de points pour voir sa profondeur, pour pouvoir positionner correctement la task-board sur RVIZ par rapport sa position réelle par rapport au robot Panda dans le réel :</p>

<table align="center" cellspacing="10" cellpadding="5" style="width: 100%">
  <tr>
      <th>
        <div class="image">
        <img src="./img/new/Nuage_points_1.png" />
        </div>
      </th>
  </tr>
  <tr>
      <th>
        <div class="image">
          <img src="./img/new/Nuage_points_2.png"/>
      </div>
      </th>
  </tr>
</table>

```{mermaid}
---

caption: Deux points de vue différents avec la task-board et sans, avec l'affichage d'un nuage de points illustrant le champs de vision de la caméra avec sa profondeur.
align: 'center'
---
graph LR

```

<br>


</li>
<li><p>Repositionnement de la TF de la caméra par rapport à son URDF pour maximiser la précision de la perception (on avait ici un décalage de l’ordre de 5 à 7 cm pour l’objectif de la caméra qui était utilisé),</p></li>
<li><p>Pour le contrôle en impédance, on a décidé de mettre une raideur au niveau du bras de robot, ce qui permettra d’éviter d’endommager la task-board.</p></li>
</div>
</ul>

## Vidéo de démonstration de la tâche

Ci-dessous, vous aviez à disposition la vidéo d'exécution de la tâche du bouton bleu par le bras de robot Panda Franka Emika :

<table align="center" cellspacing="10" cellpadding="5">
    <tr>
        <th>
            <div class="image">
            <iframe width="700" height="500" src="https://drive.google.com/file/d/12DmbrsKFBi-u6qnFnmRYRkzS8SCZlfPd/preview" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </div>
        </th>
        <th>
          <div class="image">
          <iframe width="560" height="315" src="https://www.youtube.com/embed/Pr4blN5vL-o?si=u5BuzZKbMJCg7fcE" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
          </div>
        </th>
    </tr>
<table>

```{mermaid}
---
caption: Simulation de la tâche du bouton bleu sur RVIZ et avec le robot réel
align: 'center'
---
graph LR

```

<table align="center" cellspacing="10" cellpadding="5">
    <tr>
        <th>
            <div class="image">
            <iframe width="700" height="600" src="https://drive.google.com/file/d/1RULJTtnY2u1hkRpaMECl1Cxq4LBx0Yoy/preview" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </div>
        </th>
        <th>
            <div class="image">
            <iframe width="700" height="600" src="https://drive.google.com/file/d/1GTtPPw2Bjcq6Urw9RZu8g54OrzitHxg0/preview" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </div>
        </th>
    </tr>
</table>

```{mermaid}
---
caption: Simulation de la tâche du bouton bleu avec le robot réel, vu de plus près
align: 'center'
---
graph LR

```

</section>
