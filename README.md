# Algorithm
- Convert each video into images based on frame rate(= 5)
- For a sliding 3 second window(1s step size), the behaviour is marked as courtship, if either condition is satisfied:
    1. The path vectors of two flies *interesect*  and *positively aligned*(dot product of unit vectors is positive)
    2. Distance between two flies is less than 50 pixels throughout the window duration
- After marking courtship, another check is done where for a sliding 6 second window(1s step size), the behaviour is marked as NOT courtship, if the distance between two flies are still(each flies displacement is less than 50 pixels).  

![Vector showing path of 2 flies](depict.png)
