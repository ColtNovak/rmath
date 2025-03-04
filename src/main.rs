use color_eyre::Result;
use crossterm::{
    event::{self, Event, KeyCode, KeyEvent, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use evalexpr::{
    eval_with_context, ContextWithMutableFunctions, ContextWithMutableVariables, 
    Function, HashMapContext, Value, DefaultNumericTypes
};
use ratatui::{
    prelude::*,
    widgets::{Block, Borders, Paragraph},
    Terminal,
};
use std::io;
use std::time::Duration;

struct App {
    input: String,
    exit: bool,
}

impl App {
    fn new() -> Self {
        Self {
            input: String::new(),
            exit: false,
        }
    }

    fn run(mut self, mut terminal: Terminal<impl Backend>) -> Result<()> {
        enable_raw_mode()?;
        execute!(io::stdout(), EnterAlternateScreen)?;

        while !self.exit {
            terminal.draw(|f| self.ui(f))?;
            self.handle_events()?;
        }

        disable_raw_mode()?;
        execute!(io::stdout(), LeaveAlternateScreen)?;
        Ok(())
    }

    fn handle_events(&mut self) -> Result<()> {
        if event::poll(Duration::from_millis(16))? {
            if let Event::Key(key) = event::read()? {
                self.key_press(key);
            }
        }
        Ok(())
    }

    fn key_press(&mut self, key: KeyEvent) {
        if key.kind != KeyEventKind::Press {
            return;
        }

        match key.code {
            KeyCode::Esc => self.exit = true,
            KeyCode::Char(c) => self.input.push(c),
            KeyCode::Backspace => { self.input.pop(); },
            KeyCode::Enter => self.clear_input(),
            _ => {}
        }
    }

    fn clear_input(&mut self) {
        self.input.clear();
    }

    fn ui(&self, f: &mut Frame) {
        let layout = Layout::vertical([
            Constraint::Length(3),
            Constraint::Min(1),
        ]);

        let [input_area, status_area] = layout.areas(f.area());

        let display_input = self.input
            .replace("^", "⁁")
            .replace("sqrt(", "√(")
            .replace("pi", "π")
            .replace("⁁2", "²")
            .replace("sin(", "sin(")
            .replace("cos(", "cos(")
            .replace("tan(", "tan(");

        let block = Block::default()
            .borders(Borders::ALL)
            .title("RustCalc")
            .border_style(Style::new().fg(Color::Yellow));

        let input_text = Paragraph::new(display_input)
            .block(block)
            .style(Style::new().fg(Color::White));

        let status_text = if self.input.trim().is_empty() {
            "Enter your math".to_string()
        } else {
            let mut context: HashMapContext<DefaultNumericTypes> = HashMapContext::new();
            context.set_value("pi".into(), Value::Float(std::f64::consts::PI)).unwrap();
            context.set_value("e".into(), Value::Float(std::f64::consts::E)).unwrap();

            let mut add_func = |name: &str, func: fn(f64) -> f64| {
                context.set_function(
                    name.into(),
                    Function::new(move |args| {
                        let num = args.as_float()?;
                        Ok(Value::Float(func(num)))
                    }),
                )
            };

            add_func("sin", f64::sin).unwrap();
            add_func("cos", f64::cos).unwrap();
            add_func("tan", f64::tan).unwrap();

            context.set_function("sqrt".into(), Function::new(|args| {
                let num: f64 = args.as_float()?;
                Ok(Value::Float(num.sqrt()))
            })).unwrap();

            match eval_with_context(&self.input, &context) {
                Ok(result) => format!("{} = {:.6}", self.input, result),
                Err(e) => format!("Error: {}", e),
            }
        };

        let status = Paragraph::new(status_text)
            .style(Style::new().fg(Color::White))
            .alignment(Alignment::Left);

        f.render_widget(input_text, input_area);
        f.render_widget(status, status_area);
    }
}

fn main() -> Result<()> {
    color_eyre::install()?;

    let backend = CrosstermBackend::new(io::stdout());
    let terminal = Terminal::new(backend)?;

    enable_raw_mode()?;
    execute!(io::stdout(), EnterAlternateScreen)?;

    App::new().run(terminal)?;

    disable_raw_mode()?;
    execute!(io::stdout(), LeaveAlternateScreen)?;
    Ok(())
}
