package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

type BinarySemaphore struct {
	semaphore int
	mutex     myMutex
}

type Monitor struct {
	Writing   bool
	Readers   int
	okToRead  *BinarySemaphore
	okToWrite *BinarySemaphore
}

func (bs *BinarySemaphore) Wait() {
	bs.mutex.Lock()
	for bs.semaphore <= 0 {
		bs.mutex.Unlock()
		bs.mutex.Lock()
	}
	bs.semaphore--
	bs.mutex.Unlock()
}

func (bs *BinarySemaphore) Signal() {
	bs.mutex.Lock()
	bs.semaphore++
	bs.mutex.Unlock()
}

func (m *Monitor) startRead() {
	if m.Writing || m.okToWrite != nil {
		m.okToRead.Wait()
		for m.Writing {
			m.okToRead.Wait()
		}
	}
	m.Readers += 1
	m.okToRead.Signal()
}

func (m *Monitor) stopRead() {
	m.Readers -= 1
	if m.Readers == 0 {
		m.okToWrite.Signal()
	}
}

func (m *Monitor) startWrite() {
	if m.Readers != 0 || m.Writing {
		m.okToWrite.Wait()
	}
	m.Writing = true
}

func (m *Monitor) stopWrite() {
	m.Writing = false
	if m.okToRead != nil {
		m.okToRead.Signal()
	} else {
		m.okToWrite.Signal()
	}
}

func reader(m *Monitor, id int, task chan<- mesage) {
	for {
		m.startRead()
		task <- mesage{id, 0}
		time.Sleep(time.Millisecond * time.Duration(rand.Intn(800)+400))
		m.stopRead()
		task <- mesage{id, 0}
		time.Sleep(time.Millisecond * time.Duration(rand.Intn(1200)+400))
	}
}

func writer(m *Monitor, id int, task chan<- mesage) {
	for {
		m.startWrite()
		task <- mesage{id, 1}
		time.Sleep(time.Millisecond * time.Duration(rand.Intn(800)+400))
		m.stopWrite()
		task <- mesage{id, 1}
		time.Sleep(time.Millisecond * time.Duration(rand.Intn(1000)+400))
	}
}

type mesage struct {
	id    int
	types int // 0 - czytelnik, 1 - pisarz
}

func display(taks <-chan mesage, m int, n int) {
	readers := make([]int, m)
	writers := make([]int, n)

	for i := 0; i < m; i++ {
		readers[i] = -1
	}

	for i := 0; i < n; i++ {
		writers[i] = -1
	}

	for {
		select {
		case newTask := <-taks:
			switch newTask.types {
			case 0:
				readers[newTask.id] = readers[newTask.id] * (-1)
			case 1:
				writers[newTask.id] = writers[newTask.id] * (-1)
			}
			fmt.Printf("Attendance list:\n")
			for i := 0; i < m; i++ {
				if readers[i] == 1 {
					fmt.Printf("\t%d reading\n", i)
				}
			}
			for i := 0; i < n; i++ {
				if writers[i] == 1 {
					fmt.Printf("\t%d writing\n", i)
				}
			}
			fmt.Printf("\n")
		}
	}
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: ./main <m> <n>")
		return
	}

	m, err1 := strconv.Atoi(os.Args[1])
	n, err2 := strconv.Atoi(os.Args[2])

	if err1 != nil || err2 != nil {
		fmt.Println("Error! Parameter must be integer.")
		return
	}

	rand.Seed(time.Now().UnixNano())

	displayChan := make(chan mesage)
	go display(displayChan, m, n)

	monitor := &Monitor{
		Writing:   false,
		Readers:   0,
		okToRead:  &BinarySemaphore{},
		okToWrite: &BinarySemaphore{},
	}

	for i := 0; i < n; i++ { // n writers
		go writer(monitor, i, displayChan)
	}

	for i := 0; i < m; i++ { // m readers
		go reader(monitor, i, displayChan)
	}

	time.Sleep(time.Second * 15)
}
