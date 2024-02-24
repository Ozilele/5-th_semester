package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const numPhilosophers = 8

type MyMutex struct {
  chanel chan struct{}
}

func (m *MyMutex) Lock() {
  if m.chanel == nil {
		m.chanel = make(chan struct{}, 1)
	}
  m.chanel <- struct{}{}
}

func (m *MyMutex) Unlock() {
	if m.chanel != nil {
		<-m.chanel // Odbieranie
	}
}

type Semaphore  struct {
  value int 
  mutex MyMutex
}

func (s * Semaphore) init(initialValue int) {
  s.value = initialValue
}

func (s * Semaphore) Wait() {
  s.mutex.Lock()

  for s.value <= 0 {
    s.mutex.Unlock()
    s.mutex.Lock()
  }
  s.value--
  s.mutex.Unlock()
}

func (s *Semaphore) Signal() {
  s.mutex.Lock()
  s.value++
  s.mutex.Unlock()
}

type Philosopher struct {
  id int
  leftFork, rightFork *Semaphore
  eatingList chan string
}

type DiningTable struct {
  forks []*Semaphore 
}

func (table *DiningTable) init() {
  table.forks = make([]*Semaphore, numPhilosophers)
  for i := 0; i < numPhilosophers; i++ {
    table.forks[i] = &Semaphore{}
    table.forks[i].init(1)
  }
}

func (table *DiningTable) getLeftFork(philosopherID int) *Semaphore {
	return table.forks[philosopherID]
}

func (table *DiningTable) getRightFork(philosopherID int) *Semaphore {
	return table.forks[(philosopherID + 1) % numPhilosophers]
}

func (table *DiningTable) pickUpForks(leftFork, rightFork *Semaphore, philosopherID int, eatingList chan <- string) {
  leftFork.Wait()
  rightFork.Wait()
  eatingList <- fmt.Sprintf("(%d,%d,%d)", philosopherID, (philosopherID+1) % numPhilosophers, philosopherID)
}

func (table *DiningTable) putDownForks(leftFork, rightFork *Semaphore) {
	leftFork.Signal()
	rightFork.Signal()
}

// na semaforze dwie operacje atomowe - wait(S), if S > 0 then s = s - 1, else wstrzymaj wykoanie procesu, signal(S) - jeśli są jakieś procesy wstrzymane przez S, to wznów jeden z nich, w przeciwnym razie S = S + 1
// semaphore is concerned with ensuring at most N threads can ever access code exclusively
// Filozofowie nigdy nie rozmawiają ze sobą, co stwarza zagrożenie zakleszczenia w sytuacji, gdy każdy z nich zabierze lewy widelec i będzie czekał na prawy (lub na odwrót).

func philosopherRoutine(philosopher *Philosopher, table *DiningTable, wg *sync.WaitGroup) {
  defer wg.Done()

  for {
    // Thinking
    fmt.Printf("Philosopher %d is thinking\n", philosopher.id)
    time.Sleep(time.Duration(rand.Intn(100)) * time.Millisecond)

    // Picks up forks to eat
    leftFork := table.getLeftFork(philosopher.id)
    rightFork := table.getRightFork(philosopher.id)
    table.pickUpForks(leftFork, rightFork, philosopher.id, philosopher.eatingList)

    // Eating
    fmt.Printf("Philosopher %d is eating\n", philosopher.id)
    time.Sleep(time.Duration(rand.Intn(100)) * time.Millisecond)

    
    // Put down forks after eating
		table.putDownForks(leftFork, rightFork)
  }
}

func main() {
  rand.Seed(time.Now().Unix())

  var wg sync.WaitGroup

  table := &DiningTable{}
  table.init()

  eatingList := make(chan string, 1)

  philosophers := make([]*Philosopher, numPhilosophers)

  for i := 0; i < numPhilosophers; i++ {
    philosophers[i] = &Philosopher{
      id: i,
      leftFork: table.getLeftFork(i),
      rightFork: table.getRightFork(i),
      eatingList: eatingList,
    }
  }

  for i := 0; i < numPhilosophers; i++ {
    wg.Add(1)
    go philosopherRoutine(philosophers[i], table, &wg)
  }

  go func() {
    for {
      select {
      case eatingTuple := <-eatingList:
        fmt.Printf("Eating List: %s\n", eatingTuple)
      }
    }
  }()

  // wg.Wait()
  time.Sleep(time.Second * 10)
}