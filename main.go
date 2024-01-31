package main

import (
	"fmt"
	"math/rand"
	"time"

	"github.com/go-music/music/chord"
	"github.com/hypebeast/go-osc/osc"
)

type Chord struct {
	Name  string
	Notes [4]int
}

func main() {
	notes := []string{"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
	chords := []string{"major", "minor", "major 7", "minor"}
	chordData := []Chord{}
	_ = chordData
	for _, noteName := range notes {
		for _, chordName := range chords {
			name := noteName + " " + chordName
			c := chord.Of(name)
			cd := Chord{Name: name}
			cd.Notes[3] = int(c.Notes()[0].Class) - 1 + 36
			for i, n := range c.Notes() {
				cd.Notes[i] = int(n.Class) - 1 + 36
			}
			chordData = append(chordData, cd)
			// for inversion := 1; inversion < 4; inversion++ {
			// 	cd2 := Chord{Name: name + "inv" + fmt.Sprintf("%d", inversion)}
			// 	for i := 0; i < 4; i++ {
			// 		octave := 0
			// 		if i < inversion {
			// 			octave = 1
			// 		}
			// 		cd2.Notes[i] = int(cd.Notes[i]) + (12 * octave)
			// 	}
			// 	chordData = append(chordData, cd2)
			// }
			for octave := 1; octave < 3; octave++ {
				cd2 := Chord{Name: name}
				for i := 0; i < 4; i++ {
					cd2.Notes[i] = int(cd.Notes[i]) + (12 * octave)
				}
				chordData = append(chordData, cd2)
			}

		}
	}

	chordToPlay := chordData[rand.Intn(len(chordData))]
	for {
		if chordToPlay.Notes[0] > 47 && chordToPlay.Notes[0] < 61 {
			break
		}
		chordToPlay = chordData[rand.Intn(len(chordData))]
	}
	for {
		for _, note := range chordToPlay.Notes {
			playNote(note, 0)
		}

		fmt.Println(chordToPlay.Name)
		time.Sleep(time.Duration(rand.Intn(3000)+7000) * time.Millisecond)
		// find another chord that shares at least 3 notes
		possibleChords := []Chord{}
		for _, cd := range chordData {
			sharedNotes := 0
			for _, n := range cd.Notes {
				for _, n2 := range chordToPlay.Notes {
					if n == n2 {
						sharedNotes++
					}
				}
			}
			if sharedNotes == 3 {
				possibleChords = append(possibleChords, cd)
			}
		}
		// select a random chord from the possible chords
		nextChord := possibleChords[rand.Intn(len(possibleChords))]
		// find the note that is different
		c1 := chordToPlay.Notes
		c2 := nextChord.Notes
		fmt.Println(c1, "->", c2)
		// find the note that is different in both c1 and c2
		var diffNote1 int
		var diffNote2 int
		for _, n1 := range c1 {
			found := false
			for _, n2 := range c2 {
				if n1 == n2 {
					found = true
				}
			}
			if !found {
				diffNote1 = n1
			}
		}
		for _, n2 := range c2 {
			found := false
			for _, n1 := range c1 {
				if n1 == n2 {
					found = true
				}

			}
			if !found {
				diffNote2 = n2
			}
		}
		fmt.Println(diffNote1, "->", diffNote2)

		chordToPlay = nextChord
	}

}

func playNote(n int, note_off int) {
	client := osc.NewClient("localhost", 57120)
	msg := osc.NewMessage("/play_note")
	msg.Append(int32(n))
	msg.Append(int32(note_off))
	client.Send(msg)
}
