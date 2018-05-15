# RSSI-based-OFDM-signal-classification

Due to limited licensed bands and the ever increasing traffic demands, the mobile communication industry is striving for offloading licensed bands traffic to unlicensed bands. A lot of challenges come along with the operation of **LTE in unlicensed bands while co-locating with legacy Wi-Fi operation** in unlicensed band. In this co-existing environment, it is imperative to **identify the technologies** so that an intelligent decision can be made for maintaining quality of service (QoS) requirement of users.

Next to this unlicensed co-existing environment, a second concern is the sharing of the licensed bands where **DVB-T** operates. This is called **white space reuse**. The reuse factor used in DVB-T systems leads to unused spectrum at a given location. Users can opt to use this spectrum if and only if no DVB-T transmission is present and they transmit using less power than TV broadcast stations. It is thus necessary to periodically **sense if the spectrum is unused** by the primary user or other secondary users. On the other hand the primary user, the TV broadcast stations, will want to detect if there is illegal **use of their licensed spectrum** at the time they want to use it.

## Manual feature extraction vs autonomous feature learning
Wireless technology identification can be implemented in multiple ways. We decided to use machine learning techniques, given many recent breakthroughs and success in other domains. Furthermore, it allows learning identifying wireless technologies on its own by giving it data. How we captured this data is described in the next section.

We consider two techniques for machine learning: one where we manually extract features using export knowledge and one where we give raw RSSI data to the machine learning model. The second technique exploits the autonomous feature learning capabilities of neural networks.



## Dataset description
We used two datasets that are part of the eWINE project.

The first dataset, used for training, was captured at various locations in Ghent, Belgium. The dataset can be found [here](https://github.com/ewine-project/Technology-classification-dataset).

A second dataset, used for validation, was captured at Dublin, Ireland. The dataset can be found [here](https://github.com/ewine-project/lte-wifi-iq-samples).

## Model description

## Contact
For further information, you can contact me at jaron.fontaine@ugent.be.
