/** @jsx React.DOM */
var React = require('react');

var App = React.createClass({
  render: function () {
    return (
      <div className="App">
        <div id="myModal" className="reveal-modal" data-reveal>
          <h2>Awesome. I have it.</h2>
          <p className="lead">Congratulations!!.</p>
          <p>This is a very small react component</p>
          <a className="close-reveal-modal">&#215;</a>
        </div>
      </div>
    );
  }
});

console.log(document.getElementById('app'));
React.render(<App/>, document.getElementById('app'));

module.exports = window.App = App;
