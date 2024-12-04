// ignore_for_file: avoid_banned_usage
void main() {
  final animationName = 'My_INTRO';
  final value = switch (animationName) {
    _ when animationName.contains('INTRO') => 'INTRO',
    _ when animationName.contains('DISTANCE') => 'DISTANCE',
    _ => '',
  };

  print(value);
}

// SwitchExpression
// ├── Expression: num
// ├── Cases
// │   ├── SwitchCase
// │   │   ├── Pattern: Literal(1)
// │   │   └── Expression: Literal(1)
// │   ├── SwitchCase
// │   │   ├── Pattern: Literal(2)
// │   │   └── Expression: Literal(2)
// │   └── SwitchCase
// │       ├── Pattern: Wildcard(_)
// │       └── Expression: Literal(99)


// Program
// ├── VariableDeclaration
// │   ├── Identifier: animationName
// │   └── Literal: 'My_INTRO'
// ├── VariableDeclaration
// │   ├── Identifier: value
// │   └── SwitchExpression
// │       ├── Expression: animationName
// │       └── Cases
// │           ├── SwitchCase
// │           │   ├── Pattern: Wildcard(_)
// │           │   ├── Guard: animationName.contains('INTRO')
// │           │   └── Expression: 'INTRO'
// │           ├── SwitchCase
// │           │   ├── Pattern: Wildcard(_)
// │           │   ├── Guard: animationName.contains('DISTANCE')
// │           │   └── Expression: 'DISTANCE'
// │           └── SwitchCase
// │               ├── Pattern: Wildcard(_)
// │               └── Expression: ''