---
layout: about
title: about
permalink: /
subtitle: Robotics · Whole-body control · Reinforcement learning
profile:
  align: right
  image: me.jpg
  image_circular: false
selected_papers: false
social: true
announcements:
  enabled: false
latest_posts:
  enabled: false
---

<link rel="stylesheet" href="{{ '/assets/css/research.css' | relative_url }}">

I am **Xun Kyrie Yang**, a visiting student in the [ARG](https://articulated.robots.ox.ac.uk/) at the [Oxford Robotics Institute](https://ori.ox.ac.uk/), supervised by [Prof. Ioannis Havoutis](https://ihavoutis.github.io/).

I completed my **M.Phil. in Artificial Intelligence** at [The Hong Kong University of Science and Technology (Guangzhou)](https://www.hkust-gz.edu.cn/) in October 2026, supervised by [Prof. Junwei Liang](https://junweiliang.me). Previously, I received my B.Eng. in Automation from Harbin Institute of Technology, Shenzhen.

My research focuses on **humanoid robots**, **whole-body control**, and **reinforcement learning**. I am interested in combining perception, motion imitation, and learned world models to enable agile physical interaction and collaborative loco-manipulation.

I am currently working on **[SwiftCatch](https://play.kyrielab.com)**, an egocentric framework for agile whole-body ball catching on humanoid robots, and **[MultiMimic]({{ '/projects/multimimic/' | relative_url }})**, which explores coordinated multi-humanoid loco-manipulation. My previous work includes humanoid tennis, safe locomotion, autonomous loco-manipulation, and whole-body teleoperation.

### Research interests

- Perception-driven whole-body control and dynamic humanoid interaction
- Reinforcement learning, motion imitation, and sim-to-real transfer

I also share [Isaac Lab tutorials on Bilibili](https://space.bilibili.com/2068165497), with 3k subscribers and over 100k views.

### Research in action

<div class="research-feature">
  <a href="https://play.kyrielab.com" aria-label="Open the SwiftCatch project homepage">
    <img src="{{ '/assets/img/research/swiftcatch.png' | relative_url }}" alt="SwiftCatch humanoid reaching to catch a ball, with the egocentric depth-camera view inset" width="783" height="480" loading="eager">
  </a>
  <div>
    <h4><a href="https://play.kyrielab.com">SwiftCatch ↗</a></h4>
    <p><strong>Egocentric Agile Whole-Body Ball Catching for Humanoid Robots</strong></p>
    <p>Depth-based perception and agile whole-body control for dynamic humanoid ball catching.</p>
    <a href="https://play.kyrielab.com">Project homepage & interactive demo ↗</a>
  </div>
</div>

## [publications]({{ '/publications/' | relative_url }})

<div class="publications">
{% bibliography %}
</div>
