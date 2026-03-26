# Type Porting Guide: C++ to MeTTa

This guide outlines the conventions for porting C++ types (classes, structs, and templates) to MeTTa. The focus is on clarity, consistency, and maintainability.

---

## 1. Declaring Types in MeTTa

- Every type should always be declared as `Type`.
- The structure of a type is specified using a **type constructor**.
- The type constructor:
  - Starts with `mk*`, followed by an intuitive name (e.g., `mkDeme`).
  - Returns the type it constructs.
  - Should **not** have a body that fully reduces it to another form.
  - Can be overloaded for flexibility.

### Example:
```scheme
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> Number (List Number) (List Number))
```
```scheme
(: Instance Type)
(: mkInstance (-> (List Number) Instance))

(: ScoredInstance (-> $score Type))
(: mkScoredInstance (-> (Instance $score) (ScoredInstance $score)))
```

---

## 2. Type Parameterization

A type should be **parameterized** if it can operate on different subtypes.

- Example: A `List` can hold `Int`, `Bool`, or other elements, so it should be generic.
- Parameterization occurs **at the type level**, not at the constructor.

---

## 3. Handling Inheritance

### 3.1. Regular Inheritance

- Define a **separate type** for the parent class.
- Include the parent type as an **argument** to the child's type constructor.

### Example (C++ to MeTTa):
#### C++:
```cpp
class Animal {};
class Dog : public Animal {};
```
#### MeTTa:
```metta
(: Animal Type)
(: mkAnimal (-> $name Animal))

(: Dog Type)
(: mkDog (-> Animal Dog))

!(mkDog (mkAnimal Dog))
```

### 3.2. Abstract Classes

- **Do not declare** an abstract class as a type.
- Handle polymorphism by **manually defining functions** for each concrete type.

### Example (C++ to MeTTa):
#### C++:
```cpp
class Shape { virtual double area() = 0; };
class Circle : public Shape { double area() override; };
class Square : public Shape { double area() override; };
```
#### MeTTa:
```metta
(: Circle Type)
(: Square Type)
(: area (-> Circle Float))
(: area (-> Square Float))
```

---

## 4. Naming Conventions

### 4.1. Function Naming for Data Structures

- Prefix functions with their associated data structure.
- Example:
  - `Map.insert`, `Set.insert`

### 4.2. Type vs. Constructor Naming

- Type names should be **full and descriptive**.
- Constructors can be **abbreviated for convenience**.
- Example:
  - `MultiMap` → Constructors: `NilMMap`, `ConsMMap`

### 4.3. Naming Type Constructors for Data Structures

- The constructor should reflect its function in the data structure.
- Example:
  - A `MultiMap` data structure:
    ```metta
    (: MultiMap (-> Type Type))
    (: NilMMap (MultiMap $a))
    (: ConsMMap (-> $a (MultiMap $a) (MultiMap $a)))
    ```

### 4.4. Implicit Ordering in Data Structures

- A `Map` or `Set` is **ordered by default**.
- If unordered, explicitly specify: `UnorderedMap`.
- Example:
  ```metta
  (: Map (-> $k $v Type))
  (: UnorderedMap (-> $k $v Type))
  ```

---
