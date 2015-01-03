/** @jsx React.DOM */
var React    = window.React = require('react'), // assign it to winow for react chrome extension
    App;


App = React.createClass({
  render: function () {
      return <h1>Hello World!</h1>;
  }
});

App.start = function () {
  React.render(<App/>, document.getElementById('app'));
};

module.exports = window.App = App;
