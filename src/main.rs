use color_eyre::Result;
use crossterm::{
    event::{self, Event, KeyCode, KeyEvent, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use evalexpr::eval;
use ratatui::{
    prelude::*,
    widgets::{Block, Borders, Gauge, LineGauge, List, ListItem, Paragraph, Widget},
    Frame, Terminal, TerminalOptions, Viewport,
};
use std::{io, time::Duration};

struct App {
    input: String,
    should_exit: bool,
}

impl App {
    fn new() -> Self {
        Self {
            input: String::new(),
            should_exit: false,
        }
    }

    fn run(mut self, mut terminal: Terminal<impl Backend>) -> Result<()> {
        enable_raw_mode()?;
        execute!(io::stdout(), EnterAlternateScreen)?;

        while !self.should_exit {
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
                self.handle_key(key);
            }
        }
        Ok(())
    }

    fn handle_key(&mut self, key: KeyEvent) {
        if key.kind != KeyEventKind::Press {
            return;
        }
        
        match key.code {
            KeyCode::Esc => self.should_exit = true,
            KeyCode::Char(c) => self.input.push(c),
            KeyCode::Backspace => { self.input.pop(); },
            KeyCode::Enter => self.process_input(),
            _ => {}
        }
    }

    fn process_input(&mut self) {
        self.input.clear();
    }

    fn ui(&self, f: &mut Frame) {
        let main_layout = Layout::vertical([
            Constraint::Length(3),
            Constraint::Min(1),
        ]);

        let [input_area, status_area] = main_layout.areas(f.size());

        let display_input = self.input
            .replace("^", "⁁")  
            .replace("sqrt(", "√(")
            .replace("pi", "π")
            .replace("sin(", "sin(")
            .replace("cos(", "cos(")
            .replace("tan(", "tan(");

        let input_block = Block::default()
            .borders(Borders::ALL)
            .title("RustCalc")
            .border_style(Style::new().fg(Color::Yellow));
        
        let input_text = Paragraph::new(display_input.clone())
            .block(input_block)
            .style(Style::new().fg(Color::White));

        let status_text = if self.input.trim().is_empty() {
            "Enter your math".to_string()
        } else {
            match eval(&self.input) {
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
    let mut terminal = ratatui::init_with_options(TerminalOptions {
        viewport: Viewport::Inline(20),
    });    
    enable_raw_mode()?;
    execute!(io::stdout(), EnterAlternateScreen)?;

    App::new().run(terminal)?;

    disable_raw_mode()?;
    execute!(io::stdout(), LeaveAlternateScreen)?;
    Ok(())
}
